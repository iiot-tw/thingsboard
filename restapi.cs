using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;

namespace ConsoleApp1Post
{
    class Program
    {
        static void Main(string[] args)
        {
            string url = "http://host/api/v1/$ACCESSID/telemetry";
 
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = "POST";
            request.ContentType = "application/json";

            using (var streamWriter = new StreamWriter(request.GetRequestStream()))
            {
                  string json = "{\"user\":\"test\"," +
                                "\"password\":\"bla\"}";

                  streamWriter.Write(json);
            }
             
            string responseStr = "";
            using (WebResponse response = request.GetResponse())
            { 
                using (StreamReader sr = new StreamReader(response.GetResponseStream(),Encoding.UTF8))
                {
                     responseStr = sr.ReadToEnd();
                }//end using  
            }
             
            
             Console.Write(responseStr);
             Console.ReadKey();
        }
    }
}
