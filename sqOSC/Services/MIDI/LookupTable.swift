//
//  LookupTable.swift
//  sqOSC
//
//  Created by H Allen Adams on 10/24/25.
//

import Foundation

/**
 Lookup Table using Linear Interpolation to transform a sparse parameter values
 table to a fully-populated table. This allows the data in the configuration
 to exactly match the data in the MIDI specification tables, and also allow
 quick lookup of interpolated values when creating MIDI messages at runtime.
 */
public class LookupTable {
    private let minIndex: Int
    private let maxIndex: Int
    private let lookup: [Int: Int]
    
    /**
     Initialize a lookup table based on the given sparse table.
     */
    public init(_ config: [Int: Int]) {
        self.minIndex = config.keys.min()!
        self.maxIndex = config.keys.max()!
        
        var x: [Int] = []
        var y: [Int] = []
        
        config.keys.sorted().forEach { key in
            x.append(key)
            y.append(config[key]!)
        }
        
        var table = [Int: Int](minimumCapacity: maxIndex - minIndex + 1)
        // Linear Interpolation: y = y0 + (x-x0)((y1-y0)/(x1-x0))
        for i in 1 ..< config.count {
            let x0 = x[i - 1]
            let x1 = x[i]
            let y0 = y[i - 1]
            let y1 = y[i]
            let m = Double(y1 - y0) / Double(x1 - x0)
            
            for x in x0 ... x1 {
                let y = y0 + Int(Double(x - x0) * m)
                table[x] = y
            }
        }
        
        self.lookup = table
    }
    
    /**
     Return a Parameter Value (int) for the given input. Parameter values may be
     directly from the configuration data or linearlly interpolated.
     */
    public func lookup(_ index: Int) -> Int {
        var idx = index
        if idx > maxIndex {
            idx = maxIndex
        }
        
        if idx < minIndex {
            idx = minIndex
        }
        
        return lookup[idx]!
    }
}
