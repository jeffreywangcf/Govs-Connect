//
//  GCSportType.swift
//  GovsConnect
//
//  Created by Jeffrey Wang on 2018/10/2.
//  Copyright © 2018 Eagersoft. All rights reserved.
//

import Foundation
//
enum GCSportType : String{
    case football = "Football"
    case soccer = "Soccer"
    case volleyball = "Volleyball"
    case basketball = "Basketball"
    case hockey = "Hockey"
    case baseballSoftball = "Baseball / Softball"
    case lacrosse = "Lacrosse"
    case tennis = "Tennis"
    case wrestling = "Wrestling"
    case indoorWinterTrack = "Indoor Winter Track"
    case indoorOutdoorTrack = "Indoor / Outdoor Track"
    case golf = "Golf"
    case fieldHockey = "Field Hockey"
    case crossCountry = "Cross Country"
    case alphineSkiing = "Alphine Skiing"
    case `default` = "__default__"
}
//
enum GCSportTeamType : String, CaseIterable{
    case crossCountryBV = "Varsity Boys Cross Country"
    case crossCountryBJV = "JV Boys Cross Country"
    case crossCountryGV = "Varsity Girls Cross Country"
    case crossCountryGJV = "JV Girls Cross Country"
    case fieldHockeyGV = "Varsity Girls Field Hockey"
    case fieldHockeyGJV = "JV Girls Field Hockey"
    case fieldHockeyGT = "Third Girls Field Hockey"
    case footballBV = "Varsity Football"
    case footballBJV = "JV Football"
    case soccerBV = "Varsity Boys Soccer"
    case soccerBJV = "JV Boys Soccer"
    case soccerBT = "Third Boys Soccer"
    case soccerBF = "Fourth Boys Soccer"
    case soccerGV = "Varsity Girls Soccer"
    case soccerGJV = "JV Girls Soccer"
    case soccerGT = "Third Girls Soccer"
    case volleyballGV = "Varsity Girls Volleyball"
    case volleyballGJV = "JV Girls Volleyball"
    case volleyballGT = "Third Girls Volleyball"
    case alphineSkiingBV = "Varsity Boys Alpine Ski Racing"
    case alphineSkiingBJV = "JV Boys Alpine Ski Racing"
    case alphineSkiingGV = "Varsity Girls Alpine Ski Racing"
    case alphineSkiingGJV = "JV Girls Alpine Ski Racing"
    case basketballBV = "Varsity Boys Basketball"
    case basketballBJV = "JV Boys Basketball"
    case basketballBT = "Third Boys Basketball"
    case basketballBF = "Fourth Boys Basketball"
    case basketballGV = "Varsity Girls Basketball"
    case basketballGJV = "JV Girls Basketball"
    case basketballGT = "Third Girls Basketball"
    case hockeyBV = "Varsity Boys Hockey"
    case hockeyBJV = "JV Boys Hockey"
    case hockeyGV = "Varsity Girls Hockey"
    case hockeyGJV = "JV Girls Hockey"
    case outdoorTrackGJV = "JV Girls Outdoor Track"
    case outdoorTrackGV = "Varsity Girls Outdoor Track"
    case outdoorTrackBJV = "JV Boys Outdoor Track"
    case outdoorTrackBV = "Varsity Boys Outdoor Track"
    case indoorTrackGJV = "JV Girls Indoor Winter Track"
    case indoorTrackGV = "Varsity Girls Indoor Winter Track"
    case indoorTrackBJV = "JV Boys Indoor Winter Track"
    case indoorTrackBV = "Varsity Boys Indoor Winter Track"
    case wrestlingBV = "Varsity Wrestling"
    case wrestlingBJV = "JV Wrestling"
    case baseballBV = "Varsity Baseball"
    case baseballBJV = "JV Baseball"
    case softballV = "Varsity Softball"
    case softBallJV = "JV Softball"
    case golfV = "Varsity Golf"
    case golfBJV = "JV Golf"
    case lacrosseBV = "Varsity Boys Lacrosse"
    case lacrosseBJV = "JV Boys Lacrosse"
    case lacrosseBT = "Third Boys Lacrosse"
    case lacrosseGV = "Varsity Girls Lacrosse"
    case lacrosseGJV = "JV Girls Lacrosse"
    case lacrosseGT = "Third Girls Lacrosse"
    case tennisBV = "Varsity Boys Tennis"
    case tennisBJV = "JV Boys Tennis"
    case tennisGV = "Varsity Girls Tennis"
    case tennisGJV = "JV Girls Tennis"
    case `default` = "__default__"
}
