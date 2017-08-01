This is an linux shell code sample for foglight restful api. Currently we only provide json version samples here. 

# Files
| File Name | Description |
| ------ | ------ |
| foglight-restfulapi.sh | shell script contains the sample codes. |
| data-topology-query.json | post json data for query topology. |
| jq | a tool used for parsing json, please refer to next section for this tool. |

# JQ Tool
This is a 3rd party library for parsing json data.
In our sample code, we provide default linux x86_64 jq tool. You need to download JQ tool from [JQ Tool Download Site](https://stedolan.github.io/jq/download/) if your platform is not linux x86_64. Then you need to rename your downloaded jq file to jq and override the one we provided here. 

# Posting Data
If you invoke the restful api which contains post any data to the fms server. You need to put your json data in a file just like data-topology-query.json. And then call dorequest as below:
`dorequest <host> <port> <suburl> <authtoken> POST <file location>` 
You can find a sample for it in this .sh file. 