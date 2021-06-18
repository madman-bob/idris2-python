%foreign "python: abs"
abs : Int -> Int

%foreign "python: gcd, math"
gcd : Int -> Int -> Int

main : IO ()
main = do
    putStrLn $ show $ abs $ -1
    putStrLn $ show $ gcd 4 6
