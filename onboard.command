#!/usr/bin/env sh
# vim: ts=8:sw=8:sts=8:noet:ft=sh
#
# Create admin user on macOS client
#
# Usage: o0-o.sh [USERNAME]
#
########################################################################

# Debug
#set -x

# Safety first
set -eu

# Enforce strict POSIX with pipefail if available
set -o posix	||	true #for ZSH, BASH or KSH (fails in DASH)
set -o pipefail	||	true #not strictly POSIX, but good to have

# Disclaimer
printf	'%s\n'								\
	''								\
	'************************************************************'	\
	'*** ATTENTION!!! *******************************************'	\
	'************************************************************'	\
	'By running this script, you agree to grant remote admin'	\
	'privileges to DOTDIGITAL LLC who will use remote access to'	\
	'administer this sytem.'					\
	''								\
	'Press any key to continue'

read

# Discover sudo/doas if needed
[ "$(whoami)" = "$(logname)" ]			&&
sudo=''						||
sudo=$( which sudo )

# Define username (o0-o by default)
user_name="${1-o0-o}"

# Define public SSH key
pub_key='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPoWEqeFgAsri67X5zNkT51frCZLzvfTAufpCqFaQdu7CuEmtI69t/3SlqzmZVokbH0q6OL1XQzrCFzKdgmQbdylW7AoLSEThT44BOrh+nkTO8sp89kT3HTdRt7zmhMgN0tCrIZn5Y3Tz+Vb5vBkhFWSborIiJb9EkKx6ERDY2SR8TWGeyefoTJhx2V+Q1ULTaCEQX3I9C0YGRybJ5x9jPGvhHlaACRBAGecBPi3ortOICZnbyMpe239gq/UIILHCET7b6kVW5FnYUa6ljSl0nrdUC7ho4DPbbzAr88mSU9y1q/JrnYvjr6W5D2WIeZNXmxXloZD+4MxufQNUNB2BmsaL5+FhPC2tnTazWWqWPlaO3us6kG1bvbR1WlcIxChJ4xwLOBuyKTyCFak0+hG+2CXpaJ9X37LXcYgNljfA4895Dj2HKTH/vTch8+bdpN60TDd3htWLQuipecf9x1pM563Llsql9y66i6MV0cSLhfA2AsMTup0VYpqQb/D3HAag6rdxOJUqSA6wSmOmTrdWYHKiyJkjcBOHsQ4vFcwHkWXpJdOmh4fV+zTWpkc2vjLUMUZy91M4/zAAIIb6fB6jo2t3sSc9frv0ScefcGbOSlaUEyBhRP8DKOO/Twl9Eq1Q9g+vtmFvMJvlXaVjackxd7bvGjHLRrliAHmWom/woIw=='

# Define sudo configuration path
sudo_cfg_path=/etc
sudo_cfg_subdir_mode=0750
sudo_cfg_subdir_file_mode=0440
sudo_grant_passwordless_admin='ALL=(ALL) NOPASSWD: ALL'

# Create user
$sudo	sysadminctl	-admin	-addUser	"$user_name"

# Create sudoers.d directory
sudo	touch	"${sudo_cfg_path}/sudoers.d"

sudo	chmod	"$sudo_cfg_subdir_mode"		\
		"${sudo_cfg_path}/sudoers.d"

# Grant user passwordless sudo
printf	'%s\t%s\n'	"$user_name"				\
			"$sudo_grant_passwordless_admin"	|
sudo	tee	"${sudo_cfg_path}/sudoers.d/${user_name}"	1>/dev/null

sudo	chmod	"$sudo_cfg_subdir_file_mode"			\
		"${sudo_cfg_path}/sudoers.d/${user_name}"

# Install SSH Key
sudo	-u	"$user_name"		\
[ -d "/Users/${user_name}/.ssh" ]	||
sudo	-u	"$user_name"		\
mkdir	"/Users/${user_name}/.ssh"

sudo	-u	"$user_name"			\
chmod	0700	"/Users/${user_name}/.ssh"

sudo	-u	"$user_name"					\
fgrep	-q	"$pub_key"					\
		"/Users/${user_name}/.ssh/authorized_keys"	2>/dev/null ||
echo	"$pub_key"						|
sudo	tee	-a						\
		"/Users/${user_name}/.ssh/authorized_keys"	1>/dev/null

# Enable SSH
sudo	systemsetup	-setremotelogin	on	||

printf	'%s\n'								\
	'************************************************************'	\
	'*** ACTION REQUIRED!!! *************************************'	\
	'************************************************************'	\
	'Please grant the Terminal application full disk access'	\
	'1. Go to: System Preferences > Security & Privacy > Privacy'	\
	'2. On the left, scroll down to Full Disk Access'		\
	'3. Click on Full Disk Access'					\
	'4. Check the box next to the Terminal application icon'	\
	'5. Run this script again'

exit 0
