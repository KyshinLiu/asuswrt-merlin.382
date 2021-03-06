﻿<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>Alexa & IFTTT</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/form.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
<style>
.div_table{
	display:table;
}
.div_tr{
	display:table-row;
}
.div_td{
	display:table-cell;
}
.div_desc{
	position:relative;
	vertical-align:top;
}

.div_img {
	padding: 35px 0px 100px 25px;
}

.step_1{
	width:30px;
	height:30px;
	background-position:center;
	background-attachment:fixed;
	background:url(images/New_ui/smh_step_1.png) no-repeat center;
	margin:auto;
}

.step_2{
	width:30px;
	height:30px;
	background-position:center;
	background-attachment:fixed;
	background:url(images/New_ui/smh_step_2.png) no-repeat center;
	margin:auto;
}

.step_2_text{
	width:101px;
	height:22px;
	background-position:center;
	background-attachment:fixed;
	background:url(images/New_ui/smh_step_2_text.png) no-repeat center;
	margin:auto 10px;
}

.step_3{
	width:30px;
	height:30px;
	background-position:center;
	background-attachment:fixed;
	background:url(images/New_ui/smh_step_3.png) no-repeat center;
	margin:auto;
}

.and_you_can{
	width:421px;
	height:337px;
	background-position:center;
	background-attachment:fixed;
	background:url(images/New_ui/smh_step_4_flow.png) no-repeat center;
	margin:auto;
	background-size: 421px 337px;
}

.smh_asus_router{
	width:146px;
	height:146px;
	background-position:center;
	background-attachment:fixed;
	background:url(images/New_ui/smh_asus_router.png) no-repeat center;
	margin:41px 0px 0px 287px;
	background-size: 146px 146px;
	position: absolute;
}

.alertpin{
	width:400px;
	height:auto;
	position:absolute;
	background: rgba(0,0,0,0.95);
	z-index:10;
	margin:-215px;
	border-radius:10px;
	padding:10px;
	display: none;
}

.alert_ASUS_EULA{
	width:480px;
	height:auto;
	position:absolute;
	background: rgba(0,0,0,0.9);
	z-index:10;
	margin:-215px;
	border-radius:10px;
	padding:25px;
	display: none;
}
</style>
<script>

var remaining_time = 120;
var remaining_time_min;
var remaining_time_sec;
var remaining_time_show;
var countdownid;

var external_ip = -1;
var MAX_RETRY_NUM = 5;
var external_ip_retry_cnt = MAX_RETRY_NUM;
var flag = '<% get_parameter("flag"); %>';
var AAE_MAX_RETRY_NUM = 3;

function initial(){
	show_menu();

	if(!ifttt_support){
		document.getElementById("divSwitchMenu").style.display = "none";
		document.getElementById("formfonttitle").innerHTML = "Amazon Alexa";
	}
	if('<% nvram_get("fw_lw_enable_x"); %>' == '1')
		document.getElementById("network_services_Remind").style.display = "";

	tag_control();
	get_real_ip();

	if(flag == 'from_endpoint'){
		AAE_MAX_RETRY_NUM = 10;
		get_activation_code();
	}
}

function tag_control(){
	document.getElementById("remote_control_here").style="text-decoration: underline;cursor:pointer;";
	document.getElementById("remote_control_here").onclick=function(){
		enable_remote_control();
	};
}

function show_remote_control(){
	if(stopFlag != 1 && external_ip_retry_cnt > 0)
		setTimeout("get_real_ip();", 3000);

	if(external_ip == 1 && ('<% nvram_get("ddns_enable_x"); %>' == '0' || '<% nvram_get("ddns_hostname_x"); %>' == '' || '<% nvram_get("misc_http_x"); %>' == '0'))
			document.getElementById("remote_control").style.display = "";
	else
			document.getElementById("remote_control").style.display = "none";
}

function get_real_ip(){
	$.ajax({
		url: 'get_real_ip.asp',
		dataType: 'script',
		error: function(xhr){
			setTimeout("get_real_ip();", 3000);
		},
		success: function(response){
			external_ip_retry_cnt--;
			show_remote_control();
		}
	});
}

function enable_remote_control(){
	if(confirm("<#Alexa_Register_confirm#>")){
		require(['/require/modules/makeRequest.js'], function(makeRequest){
			makeRequest.start('/enable_remote_control.cgi',hide_remote_control , function(){});
		});
	}
}

function hide_remote_control(){
	stopFlag = 1;
	showLoading(5);
	setTimeout("location.href=document.form.current_page.value", 5000);
}

function send_gen_pincode(){

	close_alert('alert_ASUS_EULA');

	if(flag == 'from_endpoint')
		location.href = "/send_IFTTTPincode.cgi";
	else
		gen_new_pincode();
}

function detcet_aae_state(){
	$.ajax({
		url: '/appGet.cgi?hook=nvram_get(aae_enable)',
		dataType: 'json',
		error: function(xhr){
		setTimeout("detcet_aae_state()", 1000);
		},
		success: function(response){
			if(response.aae_enable == '1')
				send_gen_pincode();
			else{
				AAE_MAX_RETRY_NUM--;
				if(AAE_MAX_RETRY_NUM == 0)
					send_gen_pincode();
				else
					setTimeout("detcet_aae_state()", 1000);
			}
		}
	});
}

function setting_ASUS_EULA(){
	if(document.form.ASUS_EULA_enable.checked == true){
		require(['/require/modules/makeRequest.js'], function(makeRequest){
			makeRequest.start('/enable_ASUS_EULA.cgi', function(){
				document.form.ASUS_EULA.value = "1";
				document.getElementById("eula_agree").style.display = "none";
				document.getElementById("eula_button").style.display = "none";
				document.getElementById("eula_loading").style.display = "";
				detcet_aae_state();},
				function(){});
		});
	}else{
		document.form.ASUS_EULA_enable.focus();
	}
}

function get_activation_code(){
	if(document.form.ASUS_EULA.value != 1){
		cal_panel_block("alert_ASUS_EULA");
		$('#alert_ASUS_EULA').fadeIn(1000);
	}else{
		gen_new_pincode();
	}
}

function gen_new_pincode(){
	require(['/require/modules/makeRequest.js'], function(makeRequest){
		makeRequest.start('/get_IFTTTPincode.cgi', show_alert_pin, function(){});
	});
}

function show_alert_pin(xhr){

	var response = JSON.parse(xhr.responseText);
	remaining_time = 120;

	cal_panel_block("alert_pin");
	$('#alert_pin').fadeIn(300);

	document.getElementById("gen_pin").innerHTML = response.ifttt_pincode;

	countdownfunc();
	countdownid = window.setInterval(countdownfunc,1000);
}

function close_alert(name){
	if(name == 'alert_pin'){
		clearInterval(countdownid);
	}else if(name == 'alert_ASUS_EULA'){
		document.form.ASUS_EULA_enable.checked = false;
	}
	$('#'+name).fadeOut(100);
}

function checkTime(i){
	if (i<10){
		i="0" + i
	}
	return i
}

function cal_panel_block(obj){
	var blockmarginLeft;
	if (window.innerWidth)
		winWidth = window.innerWidth;
	else if ((document.body) && (document.body.clientWidth))
		winWidth = document.body.clientWidth;

	if (document.documentElement  && document.documentElement.clientHeight && document.documentElement.clientWidth){
		winWidth = document.documentElement.clientWidth;
	}

	if(winWidth >1050){
		winPadding = (winWidth-1050)/2;
		winWidth = 1105;
		blockmarginLeft= (winWidth*0.2)+winPadding;
	}
	else if(winWidth <=1050){
		blockmarginLeft= (winWidth)*0.2 + document.body.scrollLeft;
	}

	document.getElementById(obj).style.marginLeft = (blockmarginLeft-400)+"px";
}

function countdownfunc(){
	remaining_time_min = checkTime(Math.floor(remaining_time/60));
	remaining_time_sec = checkTime(Math.floor(remaining_time%60));
	remaining_time_show = remaining_time_min +":"+ remaining_time_sec;
	document.getElementById("rtime").innerHTML = remaining_time_show;
	if (remaining_time<0){
		clearInterval(countdownid);
		setTimeout("close_alert('alert_pin');", 2000);
	}
	remaining_time--;
}

function clipboard(ID_value)
{
	var input = document.createElement('textarea');
	document.body.appendChild(input);
	if(document.getElementById(ID_value).value == undefined)
		input.value = document.getElementById(ID_value).innerHTML;
	else
		input.value = document.getElementById(ID_value).value;
	input.select();
	document.execCommand('Copy');
	input.remove();
}

</script>
</head>
<body onload="initial();" onunLoad="return unload_body();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>

<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="current_page" value="Advanced_Smart_Home_Alexa.asp">
<input type="hidden" name="next_page" value="Advanced_Smart_Home_Alexa.asp">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_wait" value="5">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>" disabled>
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="ASUS_EULA" value="<% nvram_get("ASUS_EULA"); %>">
<table class="content" align="center" cellpadding="0" cellspacing="0">
	<tr>
		<td width="17">&nbsp;</td>
	<!--=====Beginning of Main Menu=====-->
		<td valign="top" width="202">
			<div id="mainMenu"></div>
			<div id="subMenu"></div>
		</td>
		<td valign="top">
			<div id="tabMenu" class="submenuBlock"></div>
		<!--===================================Beginning of Main Content===========================================-->
			<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
				<tr>
					<td valign="top" >
						<table width="760px" border="0" cellpadding="4" cellspacing="0" class="FormTitle" id="FormTitle">
							<tbody>
							<tr>
								<td bgcolor="#4D595D" valign="top">
									<div>&nbsp;</div>
									<div id="formfonttitle" class="formfonttitle">Alexa & IFTTT - Amazon Alexa</div>
									<div id="divSwitchMenu" style="margin-top:-40px;float:right;"><div style="width:110px;height:30px;float:left;border-top-left-radius:8px;border-bottom-left-radius:8px;" class="block_filter_pressed"><div class="tab_font_color" style="text-align:center;padding-top:5px;font-size:14px">Amazon Alexa</div></div><div style="width:110px;height:30px;float:left;border-top-right-radius:8px;border-bottom-right-radius:8px;" class="block_filter"><a href="Advanced_Smart_Home_IFTTT.asp"><div class="block_filter_name">IFTTT</div></a></div></div>
									<div style="margin-left:5px;margin-top:10px;margin-bottom:10px"><img src="/images/New_ui/export/line_export.png"></div>
									<div class="div_table">
											<div class="div_tr">
												<div class="div_td div_desc" style="width:55%">
													<div style="font-weight:bolder;font-size:16px;padding:25px 40px"><#Alexa_Desc1#></div>
													<div style="padding:0px 40px;font-family:Arial, Helvetica, sans-serif;font-size:13px;">
														<span><#Alexa_Desc2#></span>
														<p style="font-size:13px;padding-top: 20px;font-style:italic;"><#Alexa_Example0#></p>
														<p style="font-size:13px;padding-left: 20px;font-style:italic;">“Alexa, ask ASUS ROUTER to turn on the Guest Network”</p>
														<p style="font-size:13px;padding-left: 20px;font-style:italic;">“Alexa, ask ASUS ROUTER upgrade to the latest firmware”</p>
														<p style="font-size:13px;padding-left: 20px;font-style:italic;">“Alexa, ask ASUS ROUTER to pause the Internet”</p>
														<a style="font-family:Arial, Helvetica, sans-serif;font-size:13px;padding-top: 2px;padding-left: 20px;font-style:italic;text-decoration: underline;cursor:pointer;" href="https://www.asus.com/us/support/FAQ/1033393" target="_blank"><#Alexa_More_Skill#></a>
														<p id="network_services_Remind" style="font-size:13px;padding-top: 10px;font-style:italic;color:#FFCC00;font-size:13px;display: none;"><#Alexa_Example_warning#></p>
													</div>
													<div style="text-align:center;padding-top:60px;font-family:Arial, Helvetica, sans-serif;font-style:italic;font-weight:lighter;font-size:18px;"><#Alexa_Register0#></div>
													<div id="remote_control" style="text-align:center;padding-top:10px;font-size:15px;color:#FFCC00;font-weight:bolder;display:none;"><#Alexa_Register1#></div> <!-- id="remote_control_here" -->
													<div class="div_img">
														<table style="width:99%">
															<div class="div_td" style="vertical-align:middle;">
																<div class="div_tr">
																	<div class="div_td" style="vertical-align:middle;">
																		<div class="step_1"></div>
																	</div>
																	<div class="div_td" style="vertical-align:middle;">
																		<div>
																			<div class="div_td" style="vertical-align:middle;">
																				<div class="step_2_text"></div>
																			</div>
																			<div class="div_td" style="vertical-align:middle;">
																				<div style="text-align:right;">
																			<input class="button_gen_short" type="button" onclick="window.open('https://www.amazon.com/ASUS-ROUTER/dp/B07285G1RK');" value="GO">
																				</div>
																			</div>
																		</div>
																	</div>
																</div>
																<div class="div_tr">
																	<div class="div_td" style="vertical-align:middle;padding-top:30px;">
																		<div class="step_2"></div>
																	</div>
																	<div class="div_td" style="vertical-align:middle;padding-top:30px;font-size:16px;padding-left:8px;">
																		<span style="color:#c0c0c0;text-decoration:underline;cursor:pointer;" onclick="get_activation_code();">Get Activation Code</span>
																	</div>
																</div>
																<div class="div_tr">
																	<div class="div_td" style="vertical-align:top;padding-top:40px;">
																		<div class="step_3"></div>
																	</div>
																	<div class="div_td" style="vertical-align:middle;padding-top:30px;font-size:16px;padding-left: 8px;">
																		<span style="color:#c0c0c0;">Paste activation code to link Amazon account and your ASUS Router</span>
																	</div>
																</div>
															</div>
															<div class="div_td" style="vertical-align:middle;padding-left:23px;padding-top: 23px;">
																	<div class="smh_asus_router"></div>
																	<div class="and_you_can"></div>
															</div>
														</table>
													</div>
													<div id="alert_ASUS_EULA" class="alert_ASUS_EULA">
														<table style="width:99%">
															<tr>
																<th colspan="2">
																	<div style="font-size:17px;padding-bottom:8px;">To get activation code for amazon acount linking, you have to agree ASUS EULA by pressing below button.</div>
																</th>
															</tr>
															<tr id="eula_agree">
																<td colspan="2">
																	<span style="font-size:15px;padding-left:20px; color:#FFCC00"><input type="checkbox" name="ASUS_EULA_enable" value="0"> I agree to the ASUS Terms of service and Privacy Policy</span>
																</td>
															</tr>
															<tr id="eula_button">
																<td>
																	<div style="text-align:right;padding:20px 10px 0px 0px;">
																		<input class="button_gen" type="button" onclick="setting_ASUS_EULA();" value="<#CTL_Agree#>">
																	</div>
																</td>
																<td>
																	<div style="text-align:left;padding:20px 0px 0px 10px;">
																		<input class="button_gen" type="button" onclick="close_alert('alert_ASUS_EULA');" value="<#CTL_close#>">
																	</div>
																</td>
															</tr>
															<tr id="eula_loading" style="display:none">
																<td width="20%" height="80" align="center"><img src="/images/loading.gif"></td>
															</tr>
														</table>
													</div>
													<div id="alert_pin" class="alertpin">
														<table style="width:99%">
															<tr>
																<th colspan="2">
																	<div style="font-size:14px;padding-bottom:8px;"><#Alexa_pin_desc#></div>
																</th>
															</tr>
															<tr>
																<td colspan="2">
																	<table class="FormTable" width="60%" border="1" align="center" cellpadding="4" cellspacing="0">
																		<tr>
																			<td>
																				<div style="text-align: center;">
																					<span style="line-height:30px;" id="gen_pin"><span>
																				</div>
																			</td>
																			<div style="text-align: right;padding-top: 10px;margin:0px 23px -30px 0px;" id='rtime'></div>
																		</tr>
																	</table>
																</td>
															</tr>
															<tr>
																<td>
																	<div style="text-align:right;padding:20px 10px 0px 0px;">
																		<input class="button_gen" type="button" onclick="clipboard('gen_pin');" value="Copy">
																	</div>
																</td>
																<td>
																	<div style="text-align:left;padding:20px 0px 0px 10px;">
																		<input class="button_gen" type="button" onclick="close_alert('alert_pin');" value="<#CTL_close#>">
																	</div>
																</td>
															</tr>
														</table>
													</div>
												</div>
											</div>
									</div>
								</td>
							</tr>
							</tbody>
						</table>
					</td>
</form>
				</tr>
			</table>
		<!--===================================Ending of Main Content===========================================-->
		</td>
		<td width="10" align="center" valign="top">&nbsp;</td>
	</tr>
</table>

<div id="footer"></div>
</body>
</html>
