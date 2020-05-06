using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace Y_STR_Finder
{
    public class YSTRLib
    {
        static string _input_vcf_gz = null;
        static string bcftools_exe = null;

       static YSTRLib _lib = null;

        public static YSTRLib getYSTRLib()
        {
            return _lib;
        }

        public YSTRLib(string input_vcf_gz)
        {
            _input_vcf_gz = input_vcf_gz;
            string exe_path = @"bin\ubin\";//Path.GetTempPath();

           bcftools_exe = exe_path + "bcftools.exe";

            //if (!File.Exists(bcftools_exe))
            //    File.WriteAllBytes(bcftools_exe, Y_STR_Finder.Properties.Resources.bcftools_exe);
            //if (!File.Exists(exe_path + "cygwin1.dll"))
            //    File.WriteAllBytes(exe_path + "cygwin1.dll", Y_STR_Finder.Properties.Resources.cygwin1_dll);
            //if (!File.Exists(exe_path + "cygz.dll"))
            //    File.WriteAllBytes(exe_path + "cygz.dll", Y_STR_Finder.Properties.Resources.cygz_dll);
            _lib = this;
        }

        public YStrResult getYSTR(long pos_start, long pos_end, string motif_regex, string filter_regex,string replace_regex)
        {

            //\bcftools.exe query -f '%POS\t[%TGT]\n' -r chrY:3131128-3131246 bam_chrY.vcf.gz > DYS393.txt
            Process p = new Process();
            p.StartInfo.FileName = bcftools_exe;
            p.StartInfo.Arguments = "query -f '%POS\\t[%TGT]\\n' -r chrY:" + pos_start + "-" + pos_end + " \"" + _input_vcf_gz + "\"";
            p.StartInfo.WorkingDirectory = ".";
            p.StartInfo.CreateNoWindow = false;
            p.StartInfo.RedirectStandardOutput = true;
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.EnvironmentVariables["CYGWIN"] = "nodosfilewarning";
            p.Start();
            string output = p.StandardOutput.ReadToEnd();
            p.WaitForExit();
            //Console.WriteLine(output);

            if (File.Exists(Path.GetTempPath() + "ystr.txt"))
                File.Delete(Path.GetTempPath() + "ystr.txt");
            File.WriteAllText(Path.GetTempPath() + "ystr.txt", output);

            return getYSTR(Path.GetTempPath() + "ystr.txt", motif_regex, filter_regex, replace_regex, pos_start,pos_end);            
        }


        private  YStrResult getYSTR(string bcfout_file, string motif_regex, string filter_regex,string replace_regex,long pos_start, long pos_end)
        {
            YStrResult result = new YStrResult();
            try
            {
            string[] data = null;
            long pos = 0;
            string allele = "";

            Dictionary<long, string> sequence = new Dictionary<long, string>();
            string tmp = "";
            foreach (string line in File.ReadLines(bcfout_file))
            {
                data = line.Split(new char[] { '\t' });
                pos = long.Parse(data[0]);
                allele = data[1].Split(new char[] { '/' })[0].Trim();

                if (sequence.ContainsKey(pos))
                {
                    tmp = sequence[pos];
                    if (tmp.Length < allele.Length)
                    {
                        sequence.Remove(pos);
                        sequence.Add(pos, allele);
                    }
                }
                else
                    sequence.Add(pos, allele);
            }

            long m_max = sequence.Keys.Max();
            long m_min = sequence.Keys.Min();

            StringBuilder sb = new StringBuilder();
            for (long i = m_min; i <= m_max; i++)
            {
                if (sequence.ContainsKey(i))
                    sb.Append(sequence[i]);
                else
                    sb.Append("N");
            }

            result.reliability=100;

            if (m_max - m_min != pos_end-pos_start)
                result.reliability = (int)((m_max - m_min) * 100 / (pos_end - pos_start));

            string seq = sb.ToString();

            if (seq.Contains("N"))
                result.reliability = (int)(((seq.Count()-seq.Count(x => x == 'N'))*result.reliability) / (m_max - m_min));

            result.raw_seq = seq;

            string html_seq = seq;

            for (long i = pos_start; i < m_min; i++)
                html_seq = "N" + html_seq;
            for (long i = m_max; i <= pos_end; i++)
                html_seq = html_seq + "N";

                if (replace_regex == "CONCAT")
                {
                    MatchCollection mc = Regex.Matches(seq, filter_regex);
                    seq = "";
                    foreach (Match m in mc)
                    {
                        seq += m.Value;
                        html_seq = html_seq.Replace(m.Value, Regex.Replace(m.Value, "(" + motif_regex + ")", "<span style='border-color:lightblue;border-style: solid; border-width: 1px;background: -webkit-linear-gradient(left top, white , lightblue); background: -o-linear-gradient(bottom right, white, lightblue); background: -moz-linear-gradient(bottom right, white, lightblue); background: linear-gradient(to bottom right, white , lightblue);color:blue'>$1</span>"));
                    }
                }
                else
                {
                    html_seq = html_seq.Replace(seq, Regex.Replace(seq, "(" + motif_regex + ")", "<span style='border-color:lightblue;border-style: solid; border-width: 1px;background: -webkit-linear-gradient(left top, white , lightblue); background: -o-linear-gradient(bottom right, white, lightblue); background: -moz-linear-gradient(bottom right, white, lightblue); background: linear-gradient(to bottom right, white , lightblue);color:blue'>$1</span>"));
                    seq = Regex.Replace(seq, filter_regex, replace_regex);
                }

            result.html_seq = html_seq.Replace("N", "<span style='color:#a0a0a0;'>&middot;</span>");

            //Console.WriteLine(">> "+seq + "\r\n");
            MatchCollection matches = Regex.Matches(seq, motif_regex);
            result.value = matches.Count;

            }
            catch (Exception)
            {
                result.value = 0;
            }
            return result;
        }
    }
}
