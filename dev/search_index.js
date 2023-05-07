var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = TDLM","category":"page"},{"location":"#TDLM","page":"Home","title":"TDLM","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for TDLM.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [TDLM]","category":"page"},{"location":"#Simulate","page":"Home","title":"Simulate","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Modules = [TDLM.Simulate]","category":"page"},{"location":"#TDLM.Simulate.Noise","page":"Home","title":"TDLM.Simulate.Noise","text":"Noise()\n\nAdd noise of a certain distribution to an array adopting the shape an structure of the array. If nothing else specified, randn is used, otherwise it is sampled from the distribution.\n\njulia> using TDLM.Simulate\n\njulia> zeros(3, 3) + Noise();\n\njulia> ones(Int16, 3, 3) + Noise([1, 2, 3]);\n\njulia> import Distributions\n\njulia> zeros(3, 3) + Noise(Distributions.Beta());\n\njulia> using StableRNGs # results above are suppressed, here reproducible:\n\njulia> zeros(2, 2) + Noise(Distributions.Normal(), StableRNG(42))\n2×2 Matrix{Float64}:\n -0.670252  1.37363\n  0.447122  1.30954\n\n\n\n\n\n","category":"type"},{"location":"#TDLM.Simulate.PatternSequence","page":"Home","title":"TDLM.Simulate.PatternSequence","text":"PatternSequence(transition, patterns)\n\nInstead of returning a state, a pattern sequence goes through the state transistions and returns the corresponding patttern.\n\njulia> S = PatternSequence(TransitionDictSequence(1 => 2, 2 => 1; rng = StableRNG(42)), [\"a\", \"b\"]);\n\njulia> collect(Iterators.take(S, 5))\n5-element Vector{String}:\n \"b\"\n \"a\"\n \"b\"\n \"a\"\n \"b\"\n\n\n\n\n\n","category":"type"},{"location":"#TDLM.Simulate.RandomSequence","page":"Home","title":"TDLM.Simulate.RandomSequence","text":"RandomSequence(dist::Union{AbstractArray, Sampleable}, [mix_fun]; [rng])\n\nRandomSequence produces an infinite sequence of random numbers on demand. Each step of the sequence is sampled from dist, the next step is a combination of the previos step as well as new random numbers. The combination is determined by a function. If no function is is given, they will simply be added.\n\njulia> import Distributions\n\njulia> s1 = RandomSequence(Distributions.MvNormal(rand_cov(2, rng = StableRNG(42))); rng = StableRNG(42));\n\njulia> s1[1:4, :] # sequence is infinite, simply index as much as you need\n4×2 Matrix{Float64}:\n -0.299517   0.0105985\n  0.314321   1.45151\n  0.370658   1.95421\n -0.0847956  1.00213\n\njulia> # dist can also be a vector, and mix can be an abitrary function\n\njulia> RandomSequence([2 4], mix = (prev, next) -> next - prev, rng = StableRNG(43))[1:5, :]\n5×1 Matrix{Int64}:\n 4\n 0\n 2\n 0\n 2\n\n\n\n\n\n","category":"type"},{"location":"#TDLM.Simulate.TransitionDictSequence","page":"Home","title":"TDLM.Simulate.TransitionDictSequence","text":"TransitionDictSequence(dict::Dict)\n\nAn instance of TransitionSequence, where the transitions are expressed as dictionary/pairing of states.\n\njulia> S = TransitionDictSequence(1 => 2, 2 => 3; rng = StableRNG(42));\n\njulia> collect(S)\n2-element Vector{Int64}:\n 2\n 3\n\n\n\n\n\n","category":"type"},{"location":"#TDLM.Simulate.TransitionSequence","page":"Home","title":"TDLM.Simulate.TransitionSequence","text":"A TransitionSequence starts in a random state, and then returns states according to the transitions till it runs out of states. The how long such a sequence is, cannot be known beforehand (might be infinite for infinite cycles of transitions).\n\n\n\n\n\n","category":"type"},{"location":"#TDLM.Simulate.chain-Tuple{Tuple}","page":"Home","title":"TDLM.Simulate.chain","text":"chain(iterators...)\n\nChain simply connects iterators but instead of collecting them, it returns again an iterator.\n\njulia> S = chain(1:2, 100:102);\n\njulia> collect(S)\n5-element Vector{Int64}:\n   1\n   2\n 100\n 101\n 102\n\n\n\n\n\n","category":"method"},{"location":"#TDLM.Simulate.default_mix-Tuple{Any, Any}","page":"Home","title":"TDLM.Simulate.default_mix","text":"default_mix(prev, next)\n\nThe default mix function simply adds together prev and next, overwriting next.\n\n\n\n\n\n","category":"method"},{"location":"#TDLM.Simulate.possible_states-Tuple{TDLM.Simulate.TransitionDictSequence}","page":"Home","title":"TDLM.Simulate.possible_states","text":"possible_states(transition::TransitionSequence)\n\nReturns the possible states a TransitionSequence may have.\n\njulia> S = TransitionDictSequence(1 => 2, 2 => 3);\n\njulia> possible_states(S) == Set(1:3)\ntrue\n\n\n\n\n\n","category":"method"},{"location":"#TDLM.Simulate.rand_cov-Tuple{Int64}","page":"Home","title":"TDLM.Simulate.rand_cov","text":"rand_cov(k::Int, [rng = Random.GLOBAL_RNG])\n\nGenerate a random covariance matrix of size k×k.\n\njulia> rand_cov(3, rng = StableRNG(42))\n3×3 LinearAlgebra.Symmetric{Float64, Matrix{Float64}}:\n  1.39477     0.156631   -0.0456395\n  0.156631    1.54293    -0.0163959\n -0.0456395  -0.0163959   0.797937\n\n\n\n\n\n","category":"method"},{"location":"#TDLM.Simulate.random_length-Tuple","page":"Home","title":"TDLM.Simulate.random_length","text":"random_length(xs::I, dist; fun = first, rng = Random.GLOBAL_RNG)\n\nrandom_length wraps a sequence but returns the first n elements, where n is choosen randomly based on dist.\n\njulia> S = random_length(1:100, [1 3]; rng = StableRNG(42));\n\njulia> collect(S)\n3-element Vector{Int64}:\n 1\n 2\n 3 \njulia> collect(S)\n1-element Vector{Int64}:\n 1\n\n\n\n\n\n","category":"method"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"EditURL = \"https://github.com/aaronpeikert/TDLM.jl/blob/main/docs/src/long/eLife.jl\"","category":"page"},{"location":"md/eLife/#eLife","page":"Translation eLife","title":"eLife","text":"","category":"section"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"Here I go over the scripts that accompied:","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"Yunzhe Liu, Raymond J Dolan, Cameron Higgins, Hector Penagos, Mark W Woolrich, H Freyja Ólafsdóttir, Caswell Barry, Zeb Kurth-Nelson, Timothy E Behrens (2021) Temporally delayed linear modelling (TDLM) measures replay in both animals and humans eLife https://doi.org/10.7554/eLife.66917","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"Specifically: https://github.com/YunzheLiu/TDLM/blob/master/Simulate_Replay.m","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"Original code, has dark background, my julia translation is in grey.","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"Of course it makes use of the functions within this package:","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"using TDLM","category":"page"},{"location":"md/eLife/#Training-Decoders","page":"Translation eLife","title":"Training Decoders","text":"","category":"section"},{"location":"md/eLife/#Simulating-Data","page":"Translation eLife","title":"Simulating Data","text":"","category":"section"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"Much of the details of the data simulation has been abstracted away and the functions are availible in the sub-package TDLM.Simulate","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"using TDLM.Simulate","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"Add other needed packages:","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"using Distributions, Lasso","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"Some parameters:","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"<script src=\"https://emgithub.com/embed-v2.js?target=https%3A%2F%2Fgithub.com%2FYunzheLiu%2FTDLM%2Fblob%2F5e8679dec3026037918057a5f38799e9b066deda%2FSimulate_Replay.m%23L7-L23&style=atom-one-dark-reasonable&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on\"></script>","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"nSensors = 273;\nnStates = 8;\nnTrainPerStim = 18;\nnothing #hide","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"Here we sample commonPattern from a normal distribution and create copies with 50% noise. See documentation for Simulate.Noise.","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"commonPattern = randn(1, nSensors);\npatterns = repeat(commonPattern, 1, 1, nStates) + Noise();\nnothing #hide","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"<script src=\"https://emgithub.com/embed-v2.js?target=https%3A%2F%2Fgithub.com%2FYunzheLiu%2FTDLM%2Fblob%2F5e8679dec3026037918057a5f38799e9b066deda%2FSimulate_Replay.m%23L47-L49&style=atom-one-dark-reasonable&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on\"></script>","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"A special pattern is only noise, therefore zeros concatinated (noise pattern is first).","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"patterns = cat(zeros(1, nSensors), patterns, dims = 3);\nnothing #hide","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"We create samples by adding irreducible error sd = 4, and obtain a three dimensionam matrix with dims: 1. observation, 2. sensor, 3. pattern/stimulus","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"trainingData = repeat(patterns, nTrainPerStim) + Noise(Normal(0, 4));\nsize(trainingData) == (nTrainPerStim, nSensors, nStates + 1)","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"<script src=\"https://emgithub.com/embed-v2.js?target=https%3A%2F%2Fgithub.com%2FYunzheLiu%2FTDLM%2Fblob%2F5e8679dec3026037918057a5f38799e9b066deda%2FSimulate_Replay.m%23L53-L65&style=atom-one-dark-reasonable&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on\"></script>","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"Four states get more noise.","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"trainingData[:, :, sample(1:nStates, 4)] += Noise();\nnothing #hide","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"Flatten trainingData (from 3dim to 2dim)","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"trainingData = reduce(vcat, trainingData[:, :, i] for i in axes(trainingData, 3));\nnothing #hide","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"<script src=\"https://emgithub.com/embed-v2.js?target=https%3A%2F%2Fgithub.com%2FYunzheLiu%2FTDLM%2Fblob%2F5e8679dec3026037918057a5f38799e9b066deda%2FSimulate_Replay.m%23L50&style=atom-one-dark-reasonable&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on\"></script>","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"trainingLabels = hcat(repeat((0:nStates), inner = nTrainPerStim));\nnothing #hide","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"<script src=\"https://emgithub.com/embed-v2.js?target=https%3A%2F%2Fgithub.com%2FYunzheLiu%2FTDLM%2Fblob%2F5e8679dec3026037918057a5f38799e9b066deda%2FSimulate_Replay.m%23L67-73&style=atom-one-dark-reasonable&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on\"></script>","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"reduce(hcat, coef(fit(LassoPath,\n        trainingData,\n        vec(trainingLabels .== i),\n        Binomial(); α=1.0, nλ=100), select = MinAICc()) for i in 1:nStates)","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"","category":"page"},{"location":"md/eLife/","page":"Translation eLife","title":"Translation eLife","text":"This page was generated using Literate.jl.","category":"page"}]
}
