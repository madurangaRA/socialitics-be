import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

type Result record {|
    string date;
    int count;
|};

service /facebook on new http:Listener(8081) {

    resource function get getLatestPageLikesCount(http:Caller caller, http:Request req) returns error? {
        http:Response resp = new;
        
        mysql:Client mysqlClient = check new (host = "mysql-910d8c3f-ba85-4197-803c-871a29817e06-facebook3110123301-c.a.aivencloud.com",
                                            user = "avnadmin",
                                            password = "",
                                            database = "facebook", port = 12845);

        stream<Result, sql:Error?> resultStream = mysqlClient->query(`SELECT * FROM likes`);
        
        // Define an array to hold JSON objects
        json[] resultOutput = [];

        check from Result {date, count} in resultStream
            do {
                // Create a JSON object for each result and add it to the array
                resultOutput.push({ "date": date, "likeCount": count });
            };

        // Set the JSON payload to the array of JSON objects
        resp.setJsonPayload(resultOutput);
        
        // Set CORS headers
        resp.addHeader("Access-Control-Allow-Origin", "*");
        resp.addHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
        resp.addHeader("Access-Control-Allow-Headers", "Content-Type");
        
        check caller->respond(resp);
    }
}
