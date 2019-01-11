# main.jl - Animated Particles
# Modified version of Luxor
push!(LOAD_PATH, "C:\\Users\\mcbaron\\Documents\\Julia")
using Luxor
# Include helper functions
include("deps.jl")

# Constants
num_particles = 50
bounds = [1360 768]
vidlength = 5 # sec
framerate = 32
numFrames = vidlength * framerate

# Instantiate num_particles random particles
liveParts = genScreen(num_particles, bounds)

screenFrames = Movie(bounds[1], bounds[2], "Particles", 0:numFrames)

# animate the whole thing
animate(screenFrames, [
    Scene(screenFrames, backdrop, 0:numFrames)
    Scene(screenFrames, drawScreen, 0:numFrames, lineartween, liveParts)
], creategif=true)

# As of 20190102 this works, but the particles seem to settle as they evolve.
