using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace AWS_Web_Interface
{
    public partial class _Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Label1.Text = "Press Button for Test Results";
        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            string result = Program.GetServiceOutput();
            Label1.Text = result;
        }

        protected void Button2_Click(object sender, EventArgs e)
        {
            string result = Program.GetRDSServiceOutput();
            Label1.Text = result;
        }
    }
}