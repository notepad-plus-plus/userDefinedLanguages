// POSE BALL SAMPLE SCRIPT

float multiplier = 1.0;
string title;
string pie;
string animation = "sit";
key avatar;
vector offset = <0.01, 0.0, 0.0>;
vector rotate = <0.0, 0.0, 0.0>;
integer showBall = TRUE;
vector initialPos;
integer perms = FALSE;
string creator = "";

// NOTECARD
string gNotecard = "Configuration";
integer gLine = 0;
key dataserver_key = NULL_KEY;

// MENU
integer handle;
integer channel;
list menu;
string currentMenu;
integer menuTimeout = 30; // Timeout du menu en secondes
integer menuTimer = 0; // Timer du menu

next_line() {
	gLine++;
	dataserver_key = llGetNotecardLine(gNotecard,gLine);
}

doMenu(key id) {
	channel = (integer)llFrand(-1 - -2147483647) + -2147483647;
	handle = llListen(channel, "", "", "");
	llSetTimerEvent(30.0);
	mainMenu(id);
}

mainMenu(key id) {
	menuTimer = llGetUnixTime() + menuTimeout;
	currentMenu = "main";
	menu = ["Size +", "Size -", "Cancel"];
	if (showBall) {
		menu += ["Hide ball"];
	}
	else {
		menu += ["Show ball"];
	}
	menu += ["Position", "Rotation", "Reset size", "Reset pos", "Reset rot"];
	if (avatar != NULL_KEY) { // If sitting
		menu += ["Stand up"];
	}
	if ((llGetInventoryPermMask(llGetObjectName(), MASK_OWNER) & PERM_COPY) && creator != "") { // If owner copy permission
		menu += ["Check resale"];
	}
	menu += ["Update"];
	llDialog(id, "\nMain menu:", menu, channel);
}

posMenu(key id) {
	menuTimer = llGetUnixTime() + menuTimeout;
	currentMenu = "pos";
	menu = ["-X", "-Y", "-Z", "+X", "+Y", "+Z"];
	if (multiplier == 1) {
		menu += ["x 10"];
	}
	else {
		menu += ["x 1"];
	}
	menu += ["Main menu", "Cancel"];
	llDialog(id, "\nPosition:", menu, channel);
}

rotateMenu(key id) {
	menuTimer = llGetUnixTime() + menuTimeout;
	currentMenu = "rotate";
	menu = ["-X°", "-Y°", "-Z°", "+X°", "+Y°", "+Z°", "+90° (X)", "+90° (Y)", "+90° (Z)"];
	if (multiplier == 1) {
		menu += ["x 10"];
	}
	else {
		menu += ["x 1"];
	}
	menu += ["Main menu", "Cancel"];
	llDialog(id, "\nRotation:", menu, channel);
}

init() {
	llSetText("Loading...", <1.0, 1.0, 1.0>, 1.0);
	llSetTouchText("Config");
	llSitTarget(offset, llEuler2Rot(rotate * DEG_TO_RAD));
	initialPos = llGetPos();
	perms = FALSE;
	avatar = NULL_KEY;
	integer notecardNotFound = TRUE;
	if (llGetInventoryNumber(INVENTORY_NOTECARD) != 0) {
		integer i;
		for (i = 0; i < llGetInventoryNumber(INVENTORY_NOTECARD); i++) {
			if (llGetInventoryName(INVENTORY_NOTECARD, i) == gNotecard) {
				notecardNotFound = FALSE;
				gLine = 0;
				dataserver_key = llGetNotecardLine(gNotecard, 0);
			}
		}
	}
	if (notecardNotFound) {
		llOwnerSay("Notecard '" + gNotecard + "' not found! Default parameters will be used.");
		title = "Sit";
		pie = "Sit";
		animation = "sit";
	}
}

default {
	state_entry() {
		init();
	}
	
	touch_start(integer number) {
		if (creator == "") { // If creator not set
			if (llDetectedKey(0) == llGetOwner()) {
				doMenu(llDetectedKey(0));
			}
		}
		else {
			if (llKey2Name(llDetectedKey(0)) == creator) {
				doMenu(llDetectedKey(0));
			}
		}
	}
	
	on_rez(integer start) {
		llResetScript();
	}

	timer() {
		if (menuTimer != 0) { // If menu is open
			if (menuTimer <= llGetUnixTime()) { // If timeout
				menuTimer = 0;
				llListenRemove(handle);
				llSetTimerEvent(0.0);
			}
		}
	}
	
	listen(integer channel, string name, key id, string button) {
		if (button == "Cancel") {
			llListenRemove(handle);
			return;
		}
		if (button == "Main menu") {
			mainMenu(id);
			return;
		}
		if (button == "Position") {
			posMenu(id);
			return;
		}
		if (button == "-X") {
			llSetPos(llGetPos() + <-0.01 * multiplier, 0.0, 0.0>);
			posMenu(id);
			return;
		}
		if (button == "+X") {
			llSetPos(llGetPos() + <0.01 * multiplier, 0.0, 0.0>);
			posMenu(id);
			return;
		}
		if (button == "-Y") {
			llSetPos(llGetPos() + <0.0, -0.01 * multiplier, 0.0>);
			posMenu(id);
			return;
		}
		if (button == "+Y") {
			llSetPos(llGetPos() + <0.0, 0.01 * multiplier, 0.0>);
			posMenu(id);
			return;
		}
		if (button == "-Z") {
			llSetPos(llGetPos() + <0.0, 0.0, -0.01 * multiplier>);
			posMenu(id);
			return;
		}
		if (button == "+Z") {
			llSetPos(llGetPos() + <0.0, 0.0, 0.01 * multiplier>);
			posMenu(id);
			return;
		}
		if (button == "x 1") {
			multiplier = 1.0;
			if (currentMenu == "pos") {
				posMenu(id);
			}
			else {
				rotateMenu(id);
			}
			return;
		}
		if (button == "x 10") {
			multiplier = 10.0;
			if (currentMenu == "pos") {
				posMenu(id);
			}
			else {
				rotateMenu(id);
			}
			return;
		}
		if (button == "Rotation") {
			rotateMenu(id);
			return;
		}
		if (button == "-X°") {
			llSetRot(llGetRot() * llEuler2Rot(<-multiplier * DEG_TO_RAD, 0.0, 0.0>));
			rotateMenu(id);
			return;
		}
		if (button == "+X°") {
			llSetRot(llGetRot() * llEuler2Rot(<multiplier * DEG_TO_RAD, 0.0, 0.0>));
			rotateMenu(id);
			return;
		}
		if (button == "+90° (X)") {
			llSetRot(llGetRot() * llEuler2Rot(<PI_BY_TWO, 0.0, 0.0>));
			rotateMenu(id);
			return;
		}
		if (button == "-Y°") {
			llSetRot(llGetRot() * llEuler2Rot(<0.0, -multiplier * DEG_TO_RAD, 0.0>));
			rotateMenu(id);
			return;
		}
		if (button == "+Y°") {
			llSetRot(llGetRot() * llEuler2Rot(<0.0, multiplier * DEG_TO_RAD, 0.0>));
			rotateMenu(id);
			return;
		}
		if (button == "+90° (Y)") {
			llSetRot(llGetRot() * llEuler2Rot(<0.0, PI_BY_TWO, 0.0>));
			rotateMenu(id);
			return;
		}
		if (button == "-Z°") {
			llSetRot(llGetRot() * llEuler2Rot(<0.0, 0.0, -multiplier * DEG_TO_RAD>));
			rotateMenu(id);
			return;
		}
		if (button == "+Z°") {
			llSetRot(llGetRot() * llEuler2Rot(<0.0, 0.0, multiplier * DEG_TO_RAD>));
			rotateMenu(id);
			return;
		}
		if (button == "+90° (Z)") {
			llSetRot(llGetRot() * llEuler2Rot(<0.0, 0.0, PI_BY_TWO>));
			rotateMenu(id);
			return;
		}
		if (button == "Size +") {
			llSetScale(llGetScale() + <0.02, 0.02, 0.02>);
			mainMenu(id);
			return;
		}
		if (button == "Size -") {
			llSetScale(llGetScale() - <0.02, 0.02, 0.02>);
			mainMenu(id);
			return;
		}
		if (button == "Show ball") {
			llSetTexture("89556747-24cb-43ed-920b-47caed15465f", ALL_SIDES);
			showBall = TRUE;
			mainMenu(id);
			return;
		}
		if (button == "Hide ball") {
			showBall = FALSE;
			llSetTexture("f54a0c32-3cd1-d49a-5b4f-7b792bebc204", ALL_SIDES);
			mainMenu(id);
			return;
		}
		if (button == "Reset pos") {
			llSetPos(initialPos);
			mainMenu(id);
			return;
		}
		if (button == "Reset rot") {
			llSetRot(<0.0, 0.0, 0.0, 1.0>);
			mainMenu(id);
			return;
		}
		if (button == "Reset size") {
			llSetScale(<0.2, 0.2, 0.2>);
			mainMenu(id);
			return;
		}
		if (button == "Stand up") {
			llUnSit(avatar);
			return;
		}
		if (button == "Update") {
			llMessageLinked(LINK_THIS, 9524, "en", id);
			mainMenu(id);
			return;
		}
		if (button == "Check resale") {
			integer permsSet = TRUE;
			if (llGetInventoryPermMask(llGetObjectName(), MASK_NEXT) & PERM_COPY) {
				llOwnerSay("You must untick the copy permission for the next owner on the script before to sell this object!");
				permsSet = FALSE;
			}
			if (llGetInventoryPermMask(gNotecard, MASK_NEXT) & PERM_COPY) {
				llOwnerSay("You must untick the copy permission for the next owner on the configuration notecard before to sell this object!");
				permsSet = FALSE;
			}
			if (llGetInventoryPermMask(gNotecard, MASK_NEXT) & PERM_MODIFY) {
				llOwnerSay("You must untick the modify permission for the next owner on the configuration notecard before to sell this object!");
				permsSet = FALSE;
			}
			if (permsSet) {
				llOwnerSay("This object can be sold.");
			}
			mainMenu(id);
		}
	}
	
	changed(integer change) {
		if (change & CHANGED_INVENTORY) {
			init();
		}
		if (change & CHANGED_LINK) {
			avatar = llAvatarOnSitTarget();
			if (avatar != NULL_KEY) { // If an avatar sits
				if (!perms) { // If no permission
					llRequestPermissions(avatar, PERMISSION_TRIGGER_ANIMATION);
				}
				else { // If permission, start animation
					llStartAnimation(animation);
				}
				llSetText("", <1.0, 1.0, 1.0>, 1.0);
			}
			else { // Otherwise the avatar stands up
				if (perms) { // If permission
					llStopAnimation(animation); // Stop animation
					perms = FALSE; // Release permission
				}
				avatar = NULL_KEY;
				llSetText(title, <1.0, 1.0, 1.0>, 1.0);
			}
		}
	}
	
	run_time_permissions(integer perm) {
		if (perm & PERMISSION_TRIGGER_ANIMATION) {
			perms = TRUE;
			llStartAnimation(animation);
			llSetText("", <1.0, 1.0, 1.0>, 1.0);
		}
		else {
			perms = FALSE;
		}
	}
	
	dataserver(key queryid, string data) {
		if (queryid == dataserver_key) {
			if (data != EOF) {
				if (gLine == 1) {
					if (llGetSubString(data, 0, -1) != "") {
						integer animNotFound = TRUE;
						if (llGetInventoryNumber(INVENTORY_ANIMATION) != 0) {
							integer i;
							for (i = 0; i < llGetInventoryNumber(INVENTORY_ANIMATION); i++) {
								if (llGetInventoryName(INVENTORY_ANIMATION, i) == llGetSubString(data, 0, -1)) {
									animNotFound = FALSE;
									animation = llGetSubString(data, 0, -1);
								}
							}
						}
						if (animNotFound) {
							llOwnerSay("Animation '" + llGetSubString(data, 0, -1) + "' not found! Default animation will be used.");
							animation = "sit";
						}
					}
					else {
						animation = "Sit";
					}
					next_line();
				}
				if (gLine == 3) {
					title = llGetSubString(data, 0, -1);
					next_line();
				}
				if (gLine == 5) {
					if (llGetSubString(data, 0, -1)) {
						pie = llGetSubString(data, 0, 8);
					}
					else {
						pie = "Sit";
					}
					llSetSitText(pie);
					next_line();
				}
				if (gLine == 7) {
					if (llGetInventoryPermMask(llGetObjectName(), MASK_OWNER) & PERM_COPY) { // If the owner has copy permission
						if (llGetSubString(data, 0, -1) != "") {
							creator = llGetSubString(data, 0, -1);
						}
						else {
							creator = "";
						}
					}
				}
				next_line();
			}
			if (data == EOF) {
				llSetText(title, <1.0, 1.0, 1.0>, 1.0);
			}
		}
	}
}