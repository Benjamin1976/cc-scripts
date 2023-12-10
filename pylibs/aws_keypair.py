
import subprocess
import json
from .general import findAWSObj, writeFile

def CreateKeyPair(args):
    debug = True
    keyName=args["keyName"]

    obj = "KeyPair"
    queryCmd = ["aws", "ec2", "describe-key-pairs", "--filters", 'Name=key-name, Values=' + keyName + '']
    specs = {"obj": "Subnet", "branch": "KeyPairs", "commands" : queryCmd, 
        "var": "keyName", "keyName": keyName, "returnVar": "KeyPairId"}
    rules = [
        {"branch": "KeyPairs", "dataVar": "KeyName", "passedVar": "keyName"}    
    ]
    
    print(f"[{obj}] ----- Checking & creating {obj}")
    if debug: print(f"[{obj}] Checking if", specs['obj'], "exists")
    keyPairId = findAWSObj(specs, rules)

    if keyPairId: 
        print(f"[{obj}] exists, skipping.")            
    else:
        print(f"[{obj}] {obj} doesn't exist, creating with keyName:", keyName)
        if debug: print( f"    keyName: {keyName}")
        
        # tags = f"{{Key=Name, Value='{subnet['name']}-{region}'}}"
        output = subprocess.check_output(["aws", "ec2", "create-key-pair", "--key-name", keyName 
                                            , "--query", "KeyMaterial" \
                                            # , "--output", "text", ">" + keyName + ".pem"
                                            ,  ]) 
        writeFile(keyName + ".pem", output.decode("utf-8"))

        output = subprocess.check_output(queryCmd) 
        snOutput = json.loads(output)

        snOutput = json.loads(output)
        keyPairId = snOutput["KeyPairs"][0]["KeyPairId"]
        print(f"[{obj}] Created {obj}: {keyPairId}")
    
    if debug: print(f"[{obj}] Finished:", obj)
    return keyPairId


def createKeyPairs(args):
    # debug = False
    # obj = "All Subnets"

    keyPairId = CreateKeyPair({"keyName": args["keyName"]})
    args["KeyPairId"] = keyPairId

    return args
