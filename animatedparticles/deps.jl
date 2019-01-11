# deps.jl - Animated Particles

using Luxor, FileIO, ImageView, LinearAlgebra, Combinatorics

mutable struct particle
    center::Point
    radius::Float64
    velocity::Float64 # number of pixels to move per screen refresh
    angle::Float64
end

import Base.mod
function Base.:mod(a::Point, b::Array{Int64, 1})
    return Point(mod(a.x, b[1]), mod(a.y, b[2]))
end

import Base.+
function Base.:+(a::particle, b::particle)
    thisCenter = a.center + b.center
    thisRadius = a.radius + b.radius
    thisVelocity = a.velocity + b.velocity
    thisAng = a.angle + b.angle

    return particle(thisCenter, thisRadius, thisVelocity, thisAng)
end

# Helper functions
function genScreen(num_parts::Int, bounds::Array{Int64})
    # Returns a vector of particles
    displayed = Vector{particle}(undef, num_parts)
    scrnDiag = norm(bounds)
    for i = 1:num_parts
        thisCenter = randompoint(-div(bounds[1],2), -div(bounds[2], 2), div(bounds[1], 2), div(bounds[2], 2))
        thisRadius = rand(1:.1:sqrt(scrnDiag))
        thisVelocity = rand(0:.1:50)
        thisAng = rand(0:.05:2*π) # granularity of .05 radians
        displayed[i] = particle(thisCenter, thisRadius, thisVelocity, thisAng)
    end
    return displayed
end

function revScreen(partsList::Vector{particle})
    # Called once for each frame to be rendered
    numParts = length(partsList)
    lineList = []
    # Need to calculate any and all overlapping circles
    for connection in arraybyindex(partsList, combinations(1:numParts, 2))
        a = connection[1]
        b = connection[2]
        if intersection2circles(a.center, a.radius, b.center, b.radius) > 0
            # add the line between the centers
            append!(lineList, [a.center b.center])
        end
    end

    return lineList
end

function drawScreen(screen::Scene, framenumber)
    # Actually handle the Luxor interface to generate an image
    partsList = screen.opts
    bounds = convert.(Int, [screen.movie.width, screen.movie.height])
    # refresh particles
    revParticles!(partsList, div.(bounds, 2))
    # refresh screen
    currLines = revScreen(partsList)
    # draw
    sethue("white")
    setline(2.5)
    setdash("solid")
    for i in 1:2:length(currLines)
        line(currLines[i], currLines[i+1], :stroke)
    end

    sethue("blue")
    setline(.5)
    for i in 1:length(partsList)
        circle(partsList[i].center, partsList[i].radius, :stroke)
    end

end


function revParticle!(a::particle, bounds::Array{Int64})
# update single particle
# NOTE: Assumes bounds define the max x, y of a point.
    # updates position given velocity/angle
    # grows/shrinks circle randomly
    delCenter = a.velocity * Point(cos(a.angle), sin(a.angle))
    tmpCenter = a.center + delCenter
    # a.center = mod(tmpCenter, 2 .* bounds) - Point(bounds[1], bounds[2])
    a.center = tmpCenter
    a.radius = rand(.9:.01:1.1) * a.radius
    a.velocity = rand(.8:.01:1.1) * a.velocity
    a.angle = rand(.5:.01:1.5) * a.angle

    return a
end


function revParticles!(partsList::Vector, bounds::Array{Int64})
    # Changes Particles between screen refreshes
    for i = 1:length(partsList)
        partsList[i] = revParticle!(partsList[i], bounds)
    end

    return partsList
end


# Animation Functions
function backdrop(scene::Scene, framenumber)
    background("black")
end


function arraybyindex(a, idx)
    res = []
    for e in idx
        push!(res, a[e])
    end
    return res
end
