<html>

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1252">
<meta name=Generator content="Microsoft Word 15 (filtered)">
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:"Calibri Light";
	panose-1:2 15 3 2 2 2 4 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:8.0pt;
	margin-left:0in;
	line-height:107%;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
h1
	{mso-style-link:"Heading 1 Char";
	margin-top:12.0pt;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:0in;
	margin-bottom:.0001pt;
	line-height:107%;
	page-break-after:avoid;
	font-size:16.0pt;
	font-family:"Calibri Light",sans-serif;
	color:#2F5496;
	font-weight:normal;}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{mso-style-link:"Title Char";
	margin:0in;
	margin-bottom:.0001pt;
	font-size:28.0pt;
	font-family:"Calibri Light",sans-serif;
	letter-spacing:-.5pt;}
p.MsoTitleCxSpFirst, li.MsoTitleCxSpFirst, div.MsoTitleCxSpFirst
	{mso-style-link:"Title Char";
	margin:0in;
	margin-bottom:.0001pt;
	font-size:28.0pt;
	font-family:"Calibri Light",sans-serif;
	letter-spacing:-.5pt;}
p.MsoTitleCxSpMiddle, li.MsoTitleCxSpMiddle, div.MsoTitleCxSpMiddle
	{mso-style-link:"Title Char";
	margin:0in;
	margin-bottom:.0001pt;
	font-size:28.0pt;
	font-family:"Calibri Light",sans-serif;
	letter-spacing:-.5pt;}
p.MsoTitleCxSpLast, li.MsoTitleCxSpLast, div.MsoTitleCxSpLast
	{mso-style-link:"Title Char";
	margin:0in;
	margin-bottom:.0001pt;
	font-size:28.0pt;
	font-family:"Calibri Light",sans-serif;
	letter-spacing:-.5pt;}
a:link, span.MsoHyperlink
	{color:#0563C1;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{color:#954F72;
	text-decoration:underline;}
p.MsoNoSpacing, li.MsoNoSpacing, div.MsoNoSpacing
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
span.Heading1Char
	{mso-style-name:"Heading 1 Char";
	mso-style-link:"Heading 1";
	font-family:"Calibri Light",sans-serif;
	color:#2F5496;}
span.TitleChar
	{mso-style-name:"Title Char";
	mso-style-link:Title;
	font-family:"Calibri Light",sans-serif;
	letter-spacing:-.5pt;}
span.UnresolvedMention
	{mso-style-name:"Unresolved Mention";
	color:#605E5C;
	background:#E1DFDD;}
.MsoChpDefault
	{font-family:"Calibri",sans-serif;}
.MsoPapDefault
	{margin-bottom:8.0pt;
	line-height:107%;}
 /* Page Definitions */
 @page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 31.5pt 1.0in 45.0pt;}
div.WordSection1
	{page:WordSection1;}
 /* List Definitions */
 ol
	{margin-bottom:0in;}
ul
	{margin-bottom:0in;}
-->
</style>

</head>

<body lang=EN-US link="#0563C1" vlink="#954F72">

<div class=WordSection1>

<p class=MsoTitle>Get Datastore utilization &amp; summary report v2 | PowerCLI</p>

<p class=MsoNormal>&nbsp;</p>

<h1>Summary </h1>

<p class=MsoNormal>As a VMware Admin or System Admin, it is required to keep monitor
your environment. We have all the monitoring parameters configured in our
VMWare environment but still, we should have some utilization report handy.  </p>

<p class=MsoNormal>Here I will cover the VMware Datastore utilization &amp;
summary report which I had created a long time ago, but this is the latest
version with some additional Dashboard formatting. </p>

<p class=MsoNormal>I used <a href="https://github.com/EvotecIT/Dashimo"><b>Dashimo</b></a><b>
v0.0.22 </b> module to generate a very nice HTML dashboard report. </p>

<p class=MsoNoSpacing>I have been asked to present the Datastore count &amp;
utilization to I started googling my requirement so I have found many good
codes that will give the LUN usage output. I started using the reference and
created own custom reporting format. </p>

<p class=MsoNoSpacing>Very good support by <a
href="https://communities.vmware.com/people/LucD">LucD</a></p>

<p class=MsoNoSpacing>&nbsp;</p>

<p class=MsoNoSpacing>This PowerCLI script will help you to get the report of
datastores along with free space Percentage. </p>

<p class=MsoNoSpacing>HTML report will help you to quickly address:</p>

<p class=MsoNoSpacing>&nbsp;</p>

<p class=MsoNoSpacing style='margin-left:.5in;text-indent:-.25in'><span
style='font-family:Wingdings'>Ø<span style='font:7.0pt "Times New Roman"'>&nbsp;
</span></span>Datastore per vCenters</p>

<p class=MsoNoSpacing style='margin-left:.5in'><img border=0 width=435
height=379 id="Picture 1"
src="Get%20Datastore%20utilization-@mol_files/image001.png"></p>

<p class=MsoNoSpacing style='margin-left:.5in'>&nbsp;</p>

<p class=MsoNoSpacing style='margin-left:.5in;text-indent:-.25in'><span
style='font-family:Wingdings'>Ø<span style='font:7.0pt "Times New Roman"'>&nbsp;
</span></span>Datastore per vClusters</p>

<p class=MsoNoSpacing style='margin-left:.5in'>&nbsp;</p>

<p class=MsoNoSpacing style='margin-left:.5in'><img border=0 width=581
height=380 id="Picture 2"
src="Get%20Datastore%20utilization-@mol_files/image002.png"></p>

<p class=MsoNoSpacing style='margin-left:.5in'>&nbsp;</p>

<p class=MsoNoSpacing style='margin-left:.5in;text-indent:-.25in'><span
style='font-family:Wingdings'>Ø<span style='font:7.0pt "Times New Roman"'>&nbsp;
</span></span>Datastore Type (Local or Shared)</p>

<p class=MsoNoSpacing style='margin-left:.5in'><img border=0 width=436
height=374 id="Picture 3"
src="Get%20Datastore%20utilization-@mol_files/image003.png"></p>

<p class=MsoNoSpacing style='margin-left:.5in'>&nbsp;</p>

<p class=MsoNoSpacing style='margin-left:.5in;text-indent:-.25in'><span
style='font-family:Wingdings'>Ø<span style='font:7.0pt "Times New Roman"'>&nbsp;
</span></span>Overprovisioned Datastore per VC</p>

<p class=MsoNoSpacing style='margin-left:.5in'><img border=0 width=441
height=374 id="Picture 4"
src="Get%20Datastore%20utilization-@mol_files/image004.png"></p>

<p class=MsoNoSpacing style='margin-left:.5in'>&nbsp;</p>

<p class=MsoNoSpacing style='margin-left:.5in;text-indent:-.25in'><span
style='font-family:Wingdings'>Ø<span style='font:7.0pt "Times New Roman"'>&nbsp;
</span></span>Number of VMs in each Datastore and Free space less than 10% -
15%</p>

<p class=MsoNoSpacing style='margin-left:.5in'><img border=0 width=678
height=146 id="Picture 5"
src="Get%20Datastore%20utilization-@mol_files/image005.png"></p>

<p class=MsoNormal>&nbsp;</p>

<p class=MsoNormal>&nbsp;</p>

<p class=MsoNormal><b><span style='font-size:14.0pt;line-height:107%'>Hope, it
will help you guys as well.  </span></b></p>

<h1>Prerequisites </h1>

<p class=MsoNormal>PowerCLI</p>

<p class=MsoNormal>Install <a href="https://github.com/EvotecIT/Dashimo">Dashimo
v0.0.22</a> module for HTML report to generate.</p>

<p class=MsoNormal>&nbsp;</p>

</div>

</body>

</html>