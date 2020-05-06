using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Y_STR_Kit_UI
{
    public partial class YSTRFrm : Form
    {
        string filename = null;

        public YSTRFrm()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            OpenFileDialog open = new OpenFileDialog();
            open.Filter = "BAM Files|*.bam|VCF Files|*.vcf";
            if (open.ShowDialog(this) == DialogResult.OK)
            {
                filename = open.FileName;
                textBox1.Text = filename;
                button2.Enabled = true;
            }
            else
            {
                filename = "";
                textBox1.Text = "";
                button2.Enabled = false;
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            if (filename.ToLower().EndsWith(".vcf"))
            {
                if (MessageBox.Show("You have selected a VCF file. Please note that the VCF file must have the indels and SNPs along with all confident sites. Do you want to proceed?\r\n\r\nIf you are unsure, try selecting a BAM file and I can take care of the rest.", "Warning!", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
                {
                    File.WriteAllText("generic_exec.bat", Y_STR_Kit_UI.Properties.Resources.console_vcf);
                }
                else
                {
                    filename = "";
                    textBox1.Text = "";
                    button2.Enabled = false;
                    return;
                }
            }
            else
            {
                // default is BAM.
                File.WriteAllText("generic_exec.bat", Y_STR_Kit_UI.Properties.Resources.console_bam);
            }

            ProcessStartInfo stinfo = new ProcessStartInfo();
            stinfo.FileName = "generic_exec.bat";
            stinfo.Arguments = "\"" + Path.GetFullPath(filename) + "\"";
            stinfo.CreateNoWindow = false;
            stinfo.UseShellExecute = true;
            stinfo.WindowStyle = ProcessWindowStyle.Maximized;
            Process.Start(stinfo);
            Application.Exit();
        }

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            Process.Start("http://www.y-str.org/2015/07/y-str-kit.html");
        }
    }
}
