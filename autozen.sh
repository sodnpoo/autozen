#!/bin/sh

#the url of _my_ domain list (not sure if this differs for other users.)
DOMLISTURL=https://portal.zen.co.uk/PageLoader.aspx?x=ZinqT%252fYrrjDf493bQZbZhhFKmS5Sau9BTPyx03bw1tWL%252bZFspyG810lZKTOnaoUwyFaL3TmBxv5nBHgEBDVQZSM0w02qP47qWanbV3lyrULz5aid%252f7y8dq%252bt%252bStBwdRHaNRYSIbj91fS8gTAbX46tcofKmiwiWexs9Dkzv0EU7mytVaBK051EN5BWHkdHifm
#zen zccout details
USERNAME=""
PASSWORD=""

#IP address to point to
#IPADDR="1.2.3.4"
IPADDR=`dig +short sodnpoo.ath.cx` #find this out from our dyndns provider


DOMAINS="sodnpoo.co.uk sodnpoo.com" #domain we wanna update (must have the zen friendly name set to the domain name)
#TTL
TTL=300

UA="Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20100101 Firefox/4.0.1"

ZENDIR=/root/bin/autozen
#temp working files
TMPDIR=$ZENDIR/tmp
COOKIEJAR=$TMPDIR/cookiejar.tmp
XMLFN=$TMPDIR/xmlfn.tmp
TIDYTMP=$TMPDIR/tidy.tmp
POSTTMP=$TMPDIR/post.tmp
DOMLISTFN=$TMPDIR/domlist.tmp
TIDYDOMLISTTMP=$TMPDIR/tidydomlist.tmp
LOCKFILE=$TMPDIR/lock.tmp

CURL=/usr/local/bin/curl
TIDY=/usr/local/bin/tidy
XSLTPROC=/usr/local/bin/xsltproc

###################################

#login and setup initial session
#uses a static form post template and sed to poke the username + password in
function zenLogin {
  #login
  #echo logging in..
  sed -e s/%%%USERNAME%%%/$USERNAME/ -e s/%%%PASSWORD%%%/$PASSWORD/ $ZENDIR/zen.login.post > $POSTTMP
  $CURL -k -s -o /dev/null -c $COOKIEJAR -d @$POSTTMP -A "$UA" https://myaccount.zen.co.uk/sign-in.aspx
}

#set the IP of the given admin page url
#fetches the html then uses zenasp.xsl to copy or modify the asp state (VIEWSTATE) params
#then form post back to the same admin page
function zenSetDynDns {
  XSLFN=zenasp.xsl
  POSTURL=$1

  #setup portal cookies + get html - firefox UA required otherwise a param doesn't get populated into the html
  $CURL -k -s -c $COOKIEJAR -b $COOKIEJAR -A "$UA" $POSTURL > $XMLFN

  #tidy up the html so xsltproc will process it
  $TIDY -q -numeric -asxhtml $XMLFN > $TIDYTMP 2> /dev/null

  #convert ipaddr to xsltproc params
  c=0
  PARAMSTR=""
  for IP in $(echo $IPADDR | tr "." "\n")
  do
    let c=c+1
    PARAMSTR="$PARAMSTR -param ip$c $IP"
  done
  #convert the html input tags to form post data
  $XSLTPROC $PARAMSTR -param ttl $TTL $ZENDIR/$XSLFN $TIDYTMP > $POSTTMP

  #post it
  $CURL -k -s -d @$POSTTMP -c $COOKIEJAR -b $COOKIEJAR -A "$UA" $POSTURL | sed -n 's|.*Successfully.*traffic to \(.*\) (.*|\1|p'

  #TODO check for success message
}

function zenSetDynDnsTTL {
  XSLFN=zenasp_ttl.xsl
  POSTURL=$1

  #setup portal cookies + get html - firefox UA required otherwise a param doesn't get populated into the html
  $CURL -k -s -c $COOKIEJAR -b $COOKIEJAR -A "$UA" $POSTURL > $XMLFN

  #tidy up the html so xsltproc will process it
  $TIDY -q -numeric -asxhtml $XMLFN > $TIDYTMP 2> /dev/null

  #convert ipaddr to xsltproc params
  c=0
  PARAMSTR=""
  for IP in $(echo $IPADDR | tr "." "\n")
  do
    let c=c+1
    PARAMSTR="$PARAMSTR -param ip$c $IP"
  done
  #convert the html input tags to form post data
  $XSLTPROC $PARAMSTR -param ttl $TTL $ZENDIR/$XSLFN $TIDYTMP > $POSTTMP

  #post it
  $CURL -k -s -d @$POSTTMP -c $COOKIEJAR -b $COOKIEJAR -A "$UA" $POSTURL | sed -n 's|.*from \(.*\)\. DNS updates can.*|\1|p'

  #TODO check for success message
}

#fetches the html of the domain list
function zenGetDomList {
  $CURL -k -s -c $COOKIEJAR -b $COOKIEJAR -A "$UA" $DOMLISTURL > $DOMLISTFN
  $TIDY -q -numeric -asxhtml $DOMLISTFN > $TIDYDOMLISTTMP 2> /dev/null
}

#extracts the relevant admin page url from the domain list html ready to used by zenSetDynDns
#uses getdomains.xsl to extract the url
#!!!must set the zen friendly name to the domains name e.g. sodnpoo.com!!!
function zenGetDomainURL {
  XSLFN=getdomains.xsl
  DOMAIN=$1
  PARAMSTR="-stringparam domain $DOMAIN"
  #convert the html input tags to form post data
  RETURN_URL=`$XSLTPROC -novalid $PARAMSTR $ZENDIR/$XSLFN $TIDYDOMLISTTMP`
}

function cleanup {
  rm $COOKIEJAR $XMLFN $TIDYTMP $POSTTMP $DOMLISTFN $TIDYDOMLISTTMP 2> /dev/null
}

if [ ! -e $LOCKFILE ]; then
  touch $LOCKFILE

  echo -n $$[$1]:
  date

  zenLogin      #login
  zenGetDomList #get and save dom list

  for D in $DOMAINS
  do
    #check domains current IP and only update different from new one
    #unless $1 == "force" then we force anyway to keep the ttl low as it defaults to 24 hours after 24 hours
    CURRIPADDR=`dig +short $D`

    echo -n "$$[$1]:$D: $CURRIPADDR -> "
    if [  "$IPADDR" != "$CURRIPADDR"  -o  "$1" == "force"  ]; then
      
      zenGetDomainURL $D
      if [ $RETURN_URL ]; then #if we couldn't find the url
        zenSetDynDns $RETURN_URL
        if [ "$1" == "force"  ]; then
          echo -n "$$[$1]:$D: "
          zenSetDynDnsTTL $RETURN_URL
        fi
      fi  
    else
      echo not updating
    fi
  done
  
  rm $LOCKFILE 2> /dev/null
fi

cleanup

