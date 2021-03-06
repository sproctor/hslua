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
{-# OPTIONS_GHC -fno-warn-deprecations #-}
{-|
Module      :  Foreign.Lua.FunctionsTest
Copyright   :  © 2017 Albert Krewinkel
License     :  MIT

Maintainer  :  Albert Krewinkel <tarleb+hslua@zeitkraut.de>
Stability   :  stable
Portability :  portable

Tests for lua C API-like functions
-}
module Foreign.Lua.FunctionsTest (tests) where

import Control.Monad (forM_)
import Foreign.Lua.Functions
import Foreign.Lua.Interop (push)
import Foreign.Lua.Types (Lua)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertBool, testCase, (@?))


-- | Specifications for Attributes parsing functions.
tests :: TestTree
tests = testGroup "Monadic functions"
  [ testGroup "copy"
    [ testCase "copies stack elements using positive indices" $
      assertBool "copied element should be equal to original" =<<
        runLua (do
          forM_ [1..5::Int] $ \n -> push n
          copy 4 3
          rawequal 4 3)
    , testCase "copies stack elements using negative indices" $
      assertBool "copied element should be equal to original" =<<
        runLua (do
          forM_ [1..5::Int] $ \n -> push n
          copy (-1) (-3)
          rawequal (-1) (-3))
    ]

  , luaTestCase "strlen, objlen, and rawlen all behave the same" $ do
      pushLuaExpr "{1, 1, 2, 3, 5, 8}"
      rlen <- rawlen (-1)
      olen <- objlen (-1)
      slen <- strlen (-1)
      return $ rlen == olen && rlen == slen && rlen == 6

  , luaTestCase "isfunction" $ do
      pushLuaExpr "function () print \"hi!\" end"
      isfunction (-1)

  , luaTestCase "isnil" $ pushLuaExpr "nil" *> isnil (-1)
  , luaTestCase "isnone" $ isnone 500 -- stack index 500 does not exist
  , luaTestCase "isnoneornil" $ do
      pushLuaExpr "nil"
      (&&) <$> isnoneornil 500 <*> isnoneornil (-1)
  ]

luaTestCase :: String -> Lua Bool -> TestTree
luaTestCase msg luaOp =
  testCase msg $ runLua luaOp @? "lua operation returned false"

pushLuaExpr :: String -> Lua ()
pushLuaExpr expr = loadstring ("return " ++ expr) *> call 0 1
