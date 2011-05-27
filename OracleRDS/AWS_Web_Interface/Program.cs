using System;
using System.Collections.Specialized;
using System.Configuration;
using System.Text;
using System.IO;
using System.Linq;

using Amazon;
using Amazon.EC2;
using Amazon.EC2.Model;
using Amazon.SimpleDB;
using Amazon.SimpleDB.Model;
using Amazon.S3;
using Amazon.S3.Model;

namespace AWS_Web_Interface
{
    public static class Program
    {
        public static string GetRDSServiceOutput()
        {
            NameValueCollection appConfig = ConfigurationManager.AppSettings;
            Amazon.RDS.AmazonRDS rds = AWSClientFactory.CreateAmazonRDSClient(
                    appConfig["AWSAccessKey"],
                    appConfig["AWSSecretKey"]
                    );
            //rds.DescribeDBEngineVersions(
            return "Ok."; // sb.ToString();
        }

        public static string GetServiceOutput()
        {
            StringBuilder sb = new StringBuilder(1024);
            using (StringWriter sr = new StringWriter(sb))
            {
                NameValueCollection appConfig = ConfigurationManager.AppSettings;

                sr.WriteLine("===========================================");
                sr.WriteLine("<br />");
                sr.WriteLine("Welcome to the AWS .NET SDK!");
                sr.WriteLine("<br />");
                sr.WriteLine("===========================================");
                sr.WriteLine("<br />");

                // Print the number of Amazon EC2 instances.
                AmazonEC2 ec2 = AWSClientFactory.CreateAmazonEC2Client(
                    appConfig["AWSAccessKey"],
                    appConfig["AWSSecretKey"]
                    );
                DescribeInstancesRequest ec2Request = new DescribeInstancesRequest();

                try
                {
                    DescribeInstancesResponse ec2Response = ec2.DescribeInstances(ec2Request);
                    int numInstances = 0;
                    numInstances = ec2Response.DescribeInstancesResult.Reservation.Count;
                    sr.WriteLine("You have " + numInstances + " Amazon EC2 instance(s) running in the US-East (Northern Virginia) region.");
                    sr.WriteLine("<br />");
                }
                catch (AmazonEC2Exception ex)
                {
                    if (ex.ErrorCode != null && ex.ErrorCode.Equals("AuthFailure"))
                    {
                        sr.WriteLine("The account you are using is not signed up for Amazon EC2.");
                        sr.WriteLine("<br />");
                        sr.WriteLine("You can sign up for Amazon EC2 at http://aws.amazon.com/ec2");
                    }
                    else
                    {
                        sr.WriteLine("Caught Exception: " + ex.Message);
                        sr.WriteLine("<br />");
                        sr.WriteLine("Response Status Code: " + ex.StatusCode);
                        sr.WriteLine("<br />");
                        sr.WriteLine("Error Code: " + ex.ErrorCode);
                        sr.WriteLine("<br />");
                        sr.WriteLine("Error Type: " + ex.ErrorType);
                        sr.WriteLine("<br />");
                        sr.WriteLine("Request ID: " + ex.RequestId);
                        sr.WriteLine("<br />");
                        sr.WriteLine("XML: " + ex.XML);
                    }
                }
                sr.WriteLine("<br />");

                // Print the number of Amazon SimpleDB domains.
                AmazonSimpleDB sdb = AWSClientFactory.CreateAmazonSimpleDBClient(
                    appConfig["AWSAccessKey"],
                    appConfig["AWSSecretKey"]
                    );
                ListDomainsRequest sdbRequest = new ListDomainsRequest();

                try
                {
                    //ListDomainsResponse sdbResponse = sdb.ListDomains(sdbRequest);

                    //if (sdbResponse.IsSetListDomainsResult())
                    //{
                    //    int numDomains = 0;
                    //    numDomains = sdbResponse.ListDomainsResult.DomainName.Count;
                    //    sr.WriteLine("You have " + numDomains + " Amazon SimpleDB domain(s) in the US-East (Northern Virginia) region.");
                    //    sr.WriteLine("<br />");
                    //}
                }
                catch (AmazonSimpleDBException ex)
                {
                    if (ex.ErrorCode != null && ex.ErrorCode.Equals("AuthFailure"))
                    {
                        sr.WriteLine("The account you are using is not signed up for Amazon SimpleDB.");
                        sr.WriteLine("<br />");
                        sr.WriteLine("You can sign up for Amazon SimpleDB at http://aws.amazon.com/simpledb");
                    }
                    else
                    {
                        sr.WriteLine("<br />");
                        sr.WriteLine("Caught Exception: " + ex.Message);
                        sr.WriteLine("<br />");
                        sr.WriteLine("Response Status Code: " + ex.StatusCode);
                        sr.WriteLine("<br />");
                        sr.WriteLine("Error Code: " + ex.ErrorCode);
                        sr.WriteLine("<br />");
                        sr.WriteLine("Error Type: " + ex.ErrorType);
                        sr.WriteLine("<br />");
                        sr.WriteLine("Request ID: " + ex.RequestId);
                        sr.WriteLine("<br />");
                        sr.WriteLine("XML: " + ex.XML);
                    }
                }
                sr.WriteLine("<br />");

                // Print the number of Amazon S3 Buckets.
                AmazonS3 s3Client = AWSClientFactory.CreateAmazonS3Client(
                    appConfig["AWSAccessKey"],
                    appConfig["AWSSecretKey"]
                    );

                try
                {
                    //ListBucketsResponse response = s3Client.ListBuckets();
                    //int numBuckets = 0;
                    //if (response.Buckets != null &&
                    //    response.Buckets.Count > 0)
                    //{
                    //    numBuckets = response.Buckets.Count;
                    //}
                    //sr.WriteLine("You have " + numBuckets + " Amazon S3 bucket(s) in the US Standard region.");
                    sr.WriteLine("<br />");
                }
                catch (AmazonS3Exception ex)
                {
                    if (ex.ErrorCode != null && (ex.ErrorCode.Equals("InvalidAccessKeyId") ||
                        ex.ErrorCode.Equals("InvalidSecurity")))
                    {
                        sr.WriteLine("Please check the provided AWS Credentials.");
                        sr.WriteLine("<br />");
                        sr.WriteLine("If you haven't signed up for Amazon S3, please visit http://aws.amazon.com/s3");
                    }
                    else
                    {
                        sr.WriteLine("Caught Exception: " + ex.Message);
                        sr.WriteLine("<br />");
                        sr.WriteLine("Response Status Code: " + ex.StatusCode);
                        sr.WriteLine("<br />");
                        sr.WriteLine("Error Code: " + ex.ErrorCode);
                        sr.WriteLine("<br />");
                        sr.WriteLine("Request ID: " + ex.RequestId);
                        sr.WriteLine("<br />");
                        sr.WriteLine("XML: " + ex.XML);
                    }
                }
            }
            return sb.ToString();
        }
    }
}