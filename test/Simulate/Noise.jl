@testset "Noise" begin
    a = zeros(5, 5)
    a2 = copy(a)
    b = a + Noise()
    @test typeof(a) === typeof(b)
    @test size(a) === size(a)
    @test a == a2 
    c = zeros(Int32, 100, 100)
    @test typeof(c) === typeof(c + Noise(Int32[1, 2, 3, 4]))
end
