
import subprocess
import os.path
import json

debug = False

configVars = ["status", "createdVPC", "createdSubnet", "createdSubnetGroup", "createdIGW", "createdRouteTbl", "createdSecurityGroup", "createdRDSdb"]
configDefault = {
    "status": "not started",
    "createdVPC": False,
    "createdSubnet": False,
    "createdSubnetGroup": False,
    "createdIGW": False,
    "createdRouteTbl": False,
    "createdSecurityGroup": False,
    "createdRDSdb": False,
    "vpcId": "", 
    "subnetIds": "", 
    "subnetGroupId": "", 
    "igwId": "", 
    "routeTableId": "",
    "securityGroup": "",
    "rdsDBArn": "",    
}

# add config items if not added
def checkConfigHasValues(configs):
    for config in configVars:
        if not config in configs:
            if debug: print(config, "not found, adding")
            configs[config] = configDefault[config]
        else:
            if debug: print(config, "found, no action")
    return configs

# retreive the config
def getConfig(configFile):
    if os.path.isfile(configFile):
        config = readJSONFile(configFile)
        config = checkConfigHasValues(config)
    else:
        config = configDefault    
    return config

# save the config
def saveConfig(configFile, data):
    writeJSONFile(configFile, data)
    
def fileExists(logFile):
  return os.path.isfile(logFile)


def readJSONFile(file):
   if debug: print("read file:", file)
   data = readFile(file)

   if debug: print("convert from json:", data)
   data = converToJSON(data)
   return data


def writeJSONFile(file, data):
   data = converToJSON(data)
   data = writeFile(file, data)


def converToJSON(data):
  # Serializing json
  return json.dumps(data, indent=4)


def convertFromJSON(data):
  # Serializing json
  if debug: print("convert from json.load:", data)
  data = json.load(data)
  
  if debug: print("convert from json.loads:", data)
  data = json.loads(data)
  return data


def writeFile(file, data):
   # Writing to sample.json
  with open(file, "w") as outfile:
    outfile.write(data)


def readJSONFile(file):
  # Opening file
  with open(file, 'r') as openfile:
      # Reading file
      return json.load(openfile)
  
def readFile(file):
  # Opening file
  with open(file, 'r') as openfile:
      # Reading file
      return openfile.read()
  

def existInTags(tags, name):
  if tags:
    return name in [x['Key'] for x in tags]
  return False
  

def getKeyValue (objs, key):
  for obj in objs:
    # print(obj['Key'], "=", key)
    if obj['Key'] == key:
        return obj['Value']
  return False


def getTagValue(obj, key):
  if 'Tags' in obj:
    tags = obj['Tags']

    if existInTags(tags, key):
      return getKeyValue (tags, key)
    elif existInTags(tags, key.capitalize()):
      return getKeyValue (tags, key.capitalize())
                  
  return False
    

def findAWSObj (specs, rules):

    debug= False
    obj = specs['obj']
    branch = specs['branch']
    checkAll = True
    found = False if checkAll else True   # set found as false 

    print(f"[{obj}] Checking {obj} for: {specs[specs['var']]}")

    # execute the command to check objects
    output = subprocess.check_output(specs['commands']) 
    data = json.loads(output)
    # if debug: print(data)
    
    if branch in data:
      for leaf in data[branch]:
          if debug: print (f"[{obj}] Checking data leaf:-")
          if debug: print (leaf)
          
          # extra key variables
          returnVal = specs['returnVar']

          # loop through rules and exit on first match
          ruleFound = False
          for rule in rules:
            # extra key variables
            key = rule['dataVar']
            keyExists = False
            name=""

            if key.upper() == "NAME":
                # check if vpc has same name
                name = getTagValue(leaf, key)
                if name:
                    if name == specs[rule['passedVar']]:
                        ruleFound = True
            else:
              # check direct variable
              # e.g. check if vpc has CIDRblock

              if debug: print(f"[{obj}] reading", key, " in ", leaf)
              if key in leaf:
                if debug: print("Key exists")
                if leaf[key] == specs[rule['passedVar']]:
                    keyExists = True
                    ruleFound = True
              else:
                  print(f"[{obj}] Cannot find key:", key)
                  return False
            
            if checkAll:      # for check all, once one negative rule passed, exit with not found
              if not ruleFound:
                found = False
                break
              else:
                found = True
            else: 
              if ruleFound:   # for check any, once one negative positive rule, exit with found
                found = True
                break
            
              

          if found:
            print(f'[{obj}] Found Existing', obj, "returning", returnVal)
            if name: print("    name:", name)
            if keyExists: print("    " + key + ":", leaf[key])          

            if returnVal in leaf: 
              print("    " + returnVal + ":", leaf[returnVal])
              return leaf[specs['returnVar']]        
            else:
              return True
    
    print(f"[{obj}] Cannot find {obj} with: {specs[specs['var']]}")
    return False


def findAWSObj2 (specs, rules):

    debug= False
    obj = specs['obj']
    branch = specs['branch']
    checkAll = True
    found = False if checkAll else True   # set found as false 

    print(f"[{obj}] Checking {obj} for: {specs[specs['var']]}")

    # execute the command to check objects
    output = subprocess.check_output(specs['commands']) 
    data = json.loads(output)
    if debug: print(data)

    # loop through rules and exit on first match
    ruleFound = False
    for rule in rules:
      # extra key variables
      key = rule['dataVar']
      keyExists = False
      name=""

      # loop through each existing item (vpc, subnet etc) and see if object exists
      for leaf in data[branch]:
          if debug: print (f"[{obj}] Checking data leaf:-")
          if debug: print (leaf)
          
          # extra key variables
          returnVal = specs['returnVar']

          if key.upper() == "NAME":
              # check if vpc has same name
              name = getTagValue(leaf, key)
              if name:
                  if name == specs[rule['passedVar']]:
                      ruleFound = True
          else:
            # check direct variable
            # e.g. check if vpc has CIDRblock

            if debug: print(f"[{obj}] reading", key, " in ", leaf)
            if key in leaf:
              if debug: print("Key exists")
              if leaf[key] == specs[rule['passedVar']]:
                  keyExists = True
                  ruleFound = True
            else:
                print(f"[{obj}] Cannot find key:", key)
                return False
          
          if checkAll:      # for check all, once one negative rule passed, exit with not found
            if not ruleFound:
              found = False
              break
            else:
                found = True
          else: 
            if ruleFound:   # for check any, once one negative positive rule, exit with found
                found = True
                break

    if found:
      print(f'[{obj}] Found Existing', obj, "returning", returnVal)
      if name: print("    name:", name)
      
      if keyExists: print("    " + key + ":", leaf[key])          

      if returnVal in leaf: 
        print("    " + returnVal + ":", leaf[returnVal])
        return leaf[specs['returnVar']]        
      else:
        return True  

        
    
    print(f"[{obj}] Cannot find {obj} with: {specs[specs['var']]}")
    return False