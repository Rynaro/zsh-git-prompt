import BranchParse (BranchInfo(MkBranchInfo), branchInfo, Distance, Branch, noBranchInfo)
import Test.QuickCheck (property, stdArgs, maxSuccess, quickCheckWithResult, Result, Property)
import Test.QuickCheck.Test (isSuccess)
import System.Exit (exitFailure)
import Control.Monad (forM, unless)


{- Helper to tackle the Either type -}

checkRight :: BranchInfo -> String -> Bool
checkRight b s = expectRight b $ branchInfo s
	where
		expectRight expected computed = case computed of
			Left _ -> False
			Right res -> res == expected

{- Test -}

propNoBranch :: Branch -> Bool
propNoBranch b =
		checkRight
			noBranchInfo
			$ show b ++ " (no branch)"

propNewRepo :: Branch -> Bool
propNewRepo b =
		checkRight 
			(MkBranchInfo (Just b) Nothing Nothing)
			$ "Initial commit on " ++ show b

propBranchOnly :: Branch -> Bool
propBranchOnly b = 
		checkRight 
			(MkBranchInfo (Just b) Nothing Nothing)
			$ show b

propBranchRemote :: Branch -> Branch -> Bool
propBranchRemote b t =
		checkRight
			(MkBranchInfo (Just b) (Just t) Nothing)
			$ show b ++"..." ++ show t 

propBranchRemoteTracking :: Branch -> Branch -> Distance -> Bool
propBranchRemoteTracking b t distance = 
		checkRight 
			(MkBranchInfo (Just b) (Just t) (Just distance))
		 	$ show b ++ "..." ++ show t ++ " " ++ show distance


allTests :: [Property]
allTests = [
				property propNoBranch,
				property propNewRepo,
				property propBranchOnly,
				property propBranchRemote,
				property propBranchRemoteTracking
				]

runTests :: IO [Result]
runTests = forM allTests $ quickCheckWithResult stdArgs { maxSuccess = 256 }

main :: IO()
main = do
	results <- runTests
	unless (all isSuccess results) exitFailure
