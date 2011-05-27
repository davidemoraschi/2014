<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="AWS_Web_Interface._Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>My AWS Enabled Application - AWS_Web_Interface</title>
</head>
<body>
    <form id="form1" runat="server">
    <h1>My AWS Stuff</h1>
    <div>
    
        <asp:Button ID="Button1" runat="server" onclick="Button1_Click" 
            Text="Test My AWS!" />
    
        <asp:Button ID="Button2" runat="server" onclick="Button2_Click" 
            Text="Test My RDS!" />
        <br />
    </div>
        <hr />
        <h1>Results</h1>
    <p>
        <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label>
    </p>

    </form>
</body>
</html>
