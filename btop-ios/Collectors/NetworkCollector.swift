import Foundation

nonisolated final class NetworkCollector: @unchecked Sendable {

    private struct InterfaceState {
        var prevBytesIn: UInt32 = 0
        var prevBytesOut: UInt32 = 0
        var cumulativeIn: UInt64 = 0
        var cumulativeOut: UInt64 = 0
        var historyIn = RingBuffer<Double>(capacity: 60, defaultValue: 0)
        var historyOut = RingBuffer<Double>(capacity: 60, defaultValue: 0)
        var initialized = false
    }

    private var states: [String: InterfaceState] = [:]

    nonisolated init() {}

    func collect(elapsed: TimeInterval) -> NetworkSnapshot {
        var linkData: [(name: String, bytesIn: UInt32, bytesOut: UInt32)] = []
        var addressMap: [String: (ipv4: String?, ipv6: String?)] = [:]

        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return NetworkSnapshot(interfaces: [], totalRateIn: 0, totalRateOut: 0)
        }
        defer { freeifaddrs(ifaddr) }

        var current = firstAddr
        while true {
            let flags = Int32(current.pointee.ifa_flags)
            let isUp = (flags & IFF_UP) != 0 && (flags & IFF_RUNNING) != 0
            let name = String(cString: current.pointee.ifa_name)

            if isUp, let ifaAddr = current.pointee.ifa_addr {
                let family = ifaAddr.pointee.sa_family

                if family == UInt8(AF_LINK), let ifaData = current.pointee.ifa_data {
                    let data = ifaData.assumingMemoryBound(to: if_data.self)
                    linkData.append((name: name, bytesIn: data.pointee.ifi_ibytes, bytesOut: data.pointee.ifi_obytes))
                } else if family == UInt8(AF_INET) {
                    var buf = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
                    ifaAddr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { sin in
                        var inAddr = sin.pointee.sin_addr
                        inet_ntop(AF_INET, &inAddr, &buf, socklen_t(INET_ADDRSTRLEN))
                    }
                    var entry = addressMap[name] ?? (ipv4: nil, ipv6: nil)
                    entry.ipv4 = String(cString: buf)
                    addressMap[name] = entry
                } else if family == UInt8(AF_INET6) {
                    var buf = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
                    ifaAddr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { sin6 in
                        var in6Addr = sin6.pointee.sin6_addr
                        inet_ntop(AF_INET6, &in6Addr, &buf, socklen_t(INET6_ADDRSTRLEN))
                    }
                    var entry = addressMap[name] ?? (ipv4: nil, ipv6: nil)
                    entry.ipv6 = String(cString: buf)
                    addressMap[name] = entry
                }
            }

            guard let next = current.pointee.ifa_next else { break }
            current = next
        }

        let dt = max(elapsed, 0.001)
        var interfaces: [InterfaceSnapshot] = []
        var totalRateIn: Double = 0
        var totalRateOut: Double = 0

        for link in linkData {
            let name = link.name
            if name == "lo0" || name.hasPrefix("awdl") || name.hasPrefix("llw") || name.hasPrefix("bridge") || name.hasPrefix("ipsec") || name.hasPrefix("anpi") {
                continue
            }

            var st = states[name] ?? InterfaceState()

            var rateIn: Double = 0
            var rateOut: Double = 0

            if st.initialized {
                let deltaIn = Self.wrappingDelta(prev: st.prevBytesIn, new: link.bytesIn)
                let deltaOut = Self.wrappingDelta(prev: st.prevBytesOut, new: link.bytesOut)
                st.cumulativeIn += deltaIn
                st.cumulativeOut += deltaOut
                rateIn = Double(deltaIn) / dt
                rateOut = Double(deltaOut) / dt
            }

            st.prevBytesIn = link.bytesIn
            st.prevBytesOut = link.bytesOut
            st.initialized = true
            st.historyIn.append(rateIn)
            st.historyOut.append(rateOut)

            let addrs = addressMap[name]

            interfaces.append(InterfaceSnapshot(
                name: name,
                displayName: Self.displayName(for: name),
                ipv4Address: addrs?.ipv4,
                ipv6Address: addrs?.ipv6,
                bytesIn: UInt64(link.bytesIn),
                bytesOut: UInt64(link.bytesOut),
                rateIn: rateIn,
                rateOut: rateOut,
                cumulativeIn: st.cumulativeIn,
                cumulativeOut: st.cumulativeOut,
                historyIn: st.historyIn.toArray(),
                historyOut: st.historyOut.toArray()
            ))

            totalRateIn += rateIn
            totalRateOut += rateOut

            states[name] = st
        }

        interfaces = interfaces.filter { iface in
            iface.ipv4Address != nil || iface.cumulativeIn > 0 || iface.cumulativeOut > 0
        }

        interfaces.sort { a, b in
            let order = ["WiFi": 0, "Cellular": 1, "VPN": 2]
            let oa = order[a.displayName] ?? 3
            let ob = order[b.displayName] ?? 3
            if oa != ob { return oa < ob }
            return a.name < b.name
        }

        return NetworkSnapshot(
            interfaces: interfaces,
            totalRateIn: totalRateIn,
            totalRateOut: totalRateOut
        )
    }

    func trimHistory() {
        for key in states.keys {
            states[key]?.historyIn.trimTo(30)
            states[key]?.historyOut.trimTo(30)
        }
    }

    private static func wrappingDelta(prev: UInt32, new: UInt32) -> UInt64 {
        if new >= prev {
            return UInt64(new) - UInt64(prev)
        }
        return UInt64(UInt32.max) - UInt64(prev) + UInt64(new) + 1
    }

    private static func displayName(for interface: String) -> String {
        if interface.hasPrefix("en") { return "WiFi" }
        if interface.hasPrefix("pdp_ip") { return "Cellular" }
        if interface.hasPrefix("utun") { return "VPN" }
        if interface.hasPrefix("bridge") { return "Bridge" }
        if interface.hasPrefix("awdl") { return "AWDL" }
        if interface.hasPrefix("llw") { return "LLW" }
        if interface == "lo0" { return "Loopback" }
        return interface
    }
}
