using TDLM

using TDLM.Simulate

using Distributions, Lasso# Some parameters:

nSensors = 273;
nStates = 8;
nTrainPerStim = 18;# Here we sample `commonPattern` from a normal distribution and create copies with 50% noise. See documentation for `Noise`.
commonPattern = randn(1, nSensors);
patterns = repeat(commonPattern, 1, 1, nStates) + Noise();

patterns = cat(zeros(1, nSensors), patterns, dims = 3);# We create samples by adding irreducible error sd = 4, and obtain a three dimensionam matrix with dims: 1. observation, 2. sensor, 3. pattern/stimulus
trainingData = repeat(patterns, nTrainPerStim) + Noise(Normal(0, 4));

trainingData[:, :, sample(1:nStates, 4)] += Noise();# Flatten `trainingData` (from 3dim to 2dim)
trainingData = reduce(vcat, trainingData[:, :, i] for i in axes(trainingData, 3));

trainingLabels = hcat(repeat((0:nStates), inner = nTrainPerStim));

        trainingData,
        vec(trainingLabels .== i),
        Binomial(); α=1.0, nλ=100), select = MinAICc()) for i in 1:nStates]...)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

