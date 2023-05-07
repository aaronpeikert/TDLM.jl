# # eLife
# 
# Here I go over the scripts that accompied:
# 
# Yunzhe Liu, Raymond J Dolan, Cameron Higgins, Hector Penagos, Mark W Woolrich, H Freyja Ólafsdóttir, Caswell Barry, Zeb Kurth-Nelson, Timothy E Behrens (2021) **Temporally delayed linear modelling (TDLM) measures replay in both animals and humans** *eLife* <https://doi.org/10.7554/eLife.66917>
# 
# Specifically: <https://github.com/YunzheLiu/TDLM/blob/master/Simulate_Replay.m>
# 
# Original code, has dark background, my julia translation is in grey.
#
# Of course it makes use of the functions within this package:
using TDLM
#
# ## Training Decoders
#
# ### Simulating Data
#
# Much of the details of the data simulation has been abstracted away and the functions are availible in the sub-package `TDLM.Simulate`
# 
using TDLM.Simulate
# Add other needed packages:
using Distributions, Lasso

# Some parameters:
# ```@raw html
# <script src="https://emgithub.com/embed-v2.js?target=https%3A%2F%2Fgithub.com%2FYunzheLiu%2FTDLM%2Fblob%2F5e8679dec3026037918057a5f38799e9b066deda%2FSimulate_Replay.m%23L7-L23&style=atom-one-dark-reasonable&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on"></script>
# ```
nSensors = 273;
nStates = 8;
nTrainPerStim = 18;

# Here we sample `commonPattern` from a normal distribution and create copies with 50% noise. See documentation for [`Simulate.Noise`](@ref).
commonPattern = randn(1, nSensors);
patterns = repeat(commonPattern, 1, 1, nStates) + Noise();
# ```@raw html
# <script src="https://emgithub.com/embed-v2.js?target=https%3A%2F%2Fgithub.com%2FYunzheLiu%2FTDLM%2Fblob%2F5e8679dec3026037918057a5f38799e9b066deda%2FSimulate_Replay.m%23L47-L49&style=atom-one-dark-reasonable&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on"></script>
# ```
# A special pattern is only noise, therefore zeros concatinated (noise pattern is first).
patterns = cat(zeros(1, nSensors), patterns, dims = 3);

# We create samples by adding irreducible error sd = 4, and obtain a three dimensionam matrix with dims: 1. observation, 2. sensor, 3. pattern/stimulus
trainingData = repeat(patterns, nTrainPerStim) + Noise(Normal(0, 4));
#md size(trainingData) == (nTrainPerStim, nSensors, nStates + 1)
# ```@raw html
# <script src="https://emgithub.com/embed-v2.js?target=https%3A%2F%2Fgithub.com%2FYunzheLiu%2FTDLM%2Fblob%2F5e8679dec3026037918057a5f38799e9b066deda%2FSimulate_Replay.m%23L53-L65&style=atom-one-dark-reasonable&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on"></script>
# ```
# Four states get more noise.
trainingData[:, :, sample(1:nStates, 4)] += Noise();

# Flatten `trainingData` (from 3dim to 2dim)
trainingData = reduce(vcat, trainingData[:, :, i] for i in axes(trainingData, 3));
# ```@raw html
# <script src="https://emgithub.com/embed-v2.js?target=https%3A%2F%2Fgithub.com%2FYunzheLiu%2FTDLM%2Fblob%2F5e8679dec3026037918057a5f38799e9b066deda%2FSimulate_Replay.m%23L50&style=atom-one-dark-reasonable&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on"></script>
# ```
trainingLabels = hcat(repeat((0:nStates), inner = nTrainPerStim));
# ```@raw html
# <script src="https://emgithub.com/embed-v2.js?target=https%3A%2F%2Fgithub.com%2FYunzheLiu%2FTDLM%2Fblob%2F5e8679dec3026037918057a5f38799e9b066deda%2FSimulate_Replay.m%23L67-73&style=atom-one-dark-reasonable&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on"></script>
# ```

reduce(hcat, coef(fit(LassoPath,
        trainingData,
        vec(trainingLabels .== i),
        Binomial(); α=1.0, nλ=100), select = MinAICc()) for i in 1:nStates)
