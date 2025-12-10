//
//  Plant.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/2/25.
//
import SwiftUI


struct Plant: Identifiable{
    var id: String
    var name: String
    var position: CGPoint
    var CropCoefficient: Double
    var date: Date
    var WaterStrain: Double
    var WaterAmount: Double
    var CumulativeDepletion: Double
    var FieldCapacity: Double
    var WiltingPoint: Double
    var p: Double //depleation factor also called MAD
    var RootDepth: Double //m
    var plantIcon: Int
}
struct Bed: Identifiable{
    var id: String
    var position: CGPoint
    var lx: Int
    var ly: Int
}
//note changing suff inside of this will not force update unless it is redevined =plant(...) so when doing plant set up have plant drager then add new thing to list and foce an update then let them chose properties

// this is a list of plant icon text


var PlantIcons: [String] = ["IMG_0125 Background Removed","IMG_0127 Background Removed","IMG_0128 Background Removed","IMG_0129 Background Removed","IMG_0133 Background Removed", "IMG_0131 Background Removed", "IMG_0130 Background Removed"]
