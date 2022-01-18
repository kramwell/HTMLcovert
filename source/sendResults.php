<?php

//$EncodedInfo = $_GET['info'];
//$EncodedInfo = "";

		$MinedCores = null;
		$ProcessorCount = null;
		$BlockHeight = null;
		$TotalBalance = null;
		$ImmatureBalance = null;
		$powDifficulty = null;
		$NetworkConnections = null;
		$CPUload = null;
		$MiningSince = null;		
		$MinedBlocks = null;		
		$Worker = null;	
		
		$DecodedInfo = null;
		
		//$DecodedInfo = "MinedCores=1;ProcessorCount=4;BlockHeight=123456;TotalBalance=2500.00000000;ImmatureBalance=1250.00300000;powDifficulty=155;NetworkConnections=8;CPUload=4.55;MiningSince=1203616089;MinedBlocks=3;Worker=rig1";

		$DecodedInfo = base64_decode($EncodedInfo);

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "htmlcovert";

// Create connection
$conn = mysqli_connect($servername, $username, $password, $dbname);
// Check connection
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

//here we loop and assign to varibles
$FullInfo = explode(";", $DecodedInfo);
foreach($FullInfo as $SplitInfo) {
    $SplitInfo = trim($SplitInfo);
	
	$SplitEquals = explode("=", $SplitInfo);
	
	//we need to check if this is valid
	//echo $SplitEquals[0];
	
	if ($SplitEquals[0] == "MinedCores"){
		//$MinedCores = $SplitEquals[0];
		$MinedCores = $SplitEquals[1];
	} elseif ($SplitEquals[0] == "ProcessorCount"){
		//$ProcessorCount = $SplitEquals[0];
		$ProcessorCount = $SplitEquals[1];
	} elseif ($SplitEquals[0] == "BlockHeight"){
		//$BlockHeight = $SplitEquals[0];
		$BlockHeight = $SplitEquals[1];
	} elseif ($SplitEquals[0] == "TotalBalance"){
		//$TotalBalance = $SplitEquals[0];
		$TotalBalance = $SplitEquals[1];
	} elseif ($SplitEquals[0] == "ImmatureBalance"){
		//$ImmatureBalance = $SplitEquals[0];
		$ImmatureBalance = $SplitEquals[1];
	} elseif ($SplitEquals[0] == "powDifficulty"){
		//$powDifficulty = $SplitEquals[0];
		$powDifficulty = $SplitEquals[1];
	} elseif ($SplitEquals[0] == "NetworkConnections"){
		//$NetworkConnections = $SplitEquals[0];
		$NetworkConnections = $SplitEquals[1];
	} elseif ($SplitEquals[0] == "CPUload"){
		//$CPUload = $SplitEquals[0];
		$CPUload = $SplitEquals[1];
	} elseif ($SplitEquals[0] == "MiningSince"){
		//$MiningSince = $SplitEquals[0];		
		$MiningSince = $SplitEquals[1];
		echo $MiningSince;
	} elseif ($SplitEquals[0] == "MinedBlocks"){
		//$MinedBlocks = $SplitEquals[0];		
		$MinedBlocks = $SplitEquals[1];
	} elseif ($SplitEquals[0] == "Worker"){
		//$Worker = $SplitEquals[0];		
		$Worker = $SplitEquals[1];
		//echo $Worker ;
	}
	
	//amount
	//echo $SplitEquals[1];
	//echo $SplitInfo."<br/>";
}

if ($MinedCores == null OR $ProcessorCount == null OR $BlockHeight == null OR $TotalBalance == null OR $ImmatureBalance == null OR $powDifficulty == null OR $NetworkConnections == null OR $CPUload == null OR $MiningSince == null OR $MinedBlocks == null OR $Worker == null){
	echo "ERROR";	
}else{

	$result=mysqli_query($conn,"SELECT Worker FROM workerInfo WHERE Worker='$Worker'");

	$row_cnt = mysqli_num_rows($result);

	//echo $row_cnt;

	//if row is nothing then add otherwise update,

	$LastSeen = time();

	if ($row_cnt == 1){
		
		$sql = "UPDATE workerInfo SET 
			   MinedCores = '$MinedCores', 
			   ProcessorCount = '$ProcessorCount', 
			   BlockHeight = '$BlockHeight', 
			   TotalBalance = '$TotalBalance', 
			   ImmatureBalance = '$ImmatureBalance',
			   powDifficulty = '$powDifficulty', 
			   NetworkConnections = '$NetworkConnections', 
			   CPUload = '$CPUload', 
			   MiningSince = '$MiningSince', 
			   MinedBlocks = '$MinedBlocks',
			   LastSeen = '$LastSeen'
		  WHERE Worker='$Worker'";
		
		//update record
		if (mysqli_query($conn, $sql)) {
			echo "1";
		} else {
			echo "Error updating record: " . mysqli_error($conn);
		}	
		
	}else{

		$sql = "INSERT INTO workerInfo (MinedCores, ProcessorCount, BlockHeight, TotalBalance, ImmatureBalance, powDifficulty, NetworkConnections, CPUload, MiningSince, MinedBlocks, LastSeen, Worker)
		VALUES ('$MinedCores', '$ProcessorCount', '$BlockHeight', '$TotalBalance', '$ImmatureBalance', '$powDifficulty', '$NetworkConnections', '$CPUload', '$MiningSince', '$MinedBlocks', '$LastSeen', '$Worker')";
			
		//update record
		if (mysqli_query($conn, $sql)) {
			echo "1";
		} else {
			echo "Error inserting record: " . mysqli_error($conn);
		}	
		
		//insert record
	}


mysqli_close($conn);

} //end if anyResults are null

//returns 1 = allgood otherwise error.

?>