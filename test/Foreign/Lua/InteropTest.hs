{-
Copyright © 2017 Albert Krewinkel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
-}
-- | Tests that lua functions can be called from haskell and vice versa.
module Foreign.Lua.InteropTest (tests) where

import Foreign.Lua.Functions
import Foreign.Lua.Interop (callfunc, peek, registerhsfunction)
import Foreign.Lua.Types (LuaNumber, Result (..))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertBool, testCase)


-- | Specifications for Attributes parsing functions.
tests :: TestTree
tests = testGroup "Interoperability"
  [ testGroup "call haskell functions from lua"
    [ testCase "push haskell function to lua" $
      let add = do
            i1 <- peek (-1)
            i2 <- peek (-2)
            -- res <- fmap (+) <$> peek (-1) <*> peek (-2)
            case (+) <$> i1 <*> i2 of
              Success x -> return x
              Error _ -> lerror
          luaOp = do
            registerhsfunction "add" add
            loadstring "return add(23, 5) == 28" *> call 0 1
            res <- peek (-1)
            return $ res == Success True
      in assertBool "Operation was successful" =<< runLua luaOp
    ]

  , testGroup "call lua function from haskell"
    [ testCase "test equality within lua" $
      assertBool "raw equality test failed" =<<
      runLua (openlibs *> callfunc "rawequal" (5 :: Int) (5.0 :: LuaNumber))
    ]
  ]
