using TestSetExtensions
using Suppressor

if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
end

orig_color = Base.have_color

eval(Base, :(have_color = true))
output_color = @capture_out begin
    @testset DottedTestSet "top-level tests" begin
        @testset "2nd-level tests 1" begin
            @test true
            @test 1 == 1
        end
        @testset "2nd-level tests 2" begin
            @test true
            @test 1 == 1
        end
    end
end

eval(Base, :(have_color = false))
output_nocolor = @capture_out begin
    @testset DottedTestSet "top-level tests" begin
        @testset "2nd-level tests 1" begin
            @test true
            @test 1 == 1
        end
        @testset "2nd-level tests 2" begin
            @test true
            @test 1 == 1
        end
    end
end

eval(Base, :(have_color = $orig_color))

@testset DottedTestSet "TextSetExtensions Tests" begin
    @testset "check output" begin
        @test split(output_color, '\n')[1] == "\e[1m\e[32m.\e[0m\e[1m\e[32m.\e[0m\e[1m\e[32m.\e[0m\e[1m\e[32m.\e[0m"
        @test split(output_nocolor, '\n')[1] == "...."
    end

    @testset "Auto-run test files" begin
        global file1_run = false
        global file2_run = false
        global file3_run = false

        @includetests

        @test file1_run
        @test file2_run
        @test file3_run
    end

    @testset "run selected test files" begin
        global file1_run = false
        global file2_run = false
        global file3_run = false

        @includetests ["file1", "file3"]

        @test file1_run
        @test !file2_run
        @test file3_run
    end

    @testset "more than one arg to @includetests is an error" begin
        ex = macroexpand(:(@includetests one two))
        @test ex.head == :error
    end
end
