#!/bin/sh

#the url of _my_ domain list (not sure if this differs for other users.)
DOMLISTURL=https://portal.zen.co.uk/PageLoader.aspx?x=ZinqT%252fYrrjDf493bQZbZhhFKmS5Sau9BTPyx03bw1tWL%252bZFspyG810lZKTOnaoUwyFaL3TmBxv5nBHgEBDVQZSM0w02qP47qWanbV3lyrULz5aid%252f7y8dq%252bt%252bStBwdRHaNRYSIbj91fS8gTAbX46tcofKmiwiWexs9Dkzv0EU7mytVaBK051EN5BWHkdHifm
#zen zccout details
USERNAME=""
PASSWORD=""

#IP address to point to
IPADDR=`dig +short sodnpoo.ath.cx` #find this out from our dyndns provider


DOMAINS="sodnpoo.co.uk sodnpoo.com" #domain we wanna update (must have the zen friendly name set to the domain name)
#TTL
TTL=600

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

###################################

#login and setup initial session
#uses a static form post temple and sed to poke the username + password in
function zenLogin {
  #login
  #echo logging in..
  sed -e s/%%%USERNAME%%%/$USERNAME/ -e s/%%%PASSWORD%%%/$PASSWORD/ $ZENDIR/zen.login.post > $POSTTMP
  #curl -s -o /dev/null -c $COOKIEJAR -d @$POSTTMP -A "$UA" https://myaccount.zen.co.uk/sign-in.aspx
  curl -k -s -o /dev/null -c $COOKIEJAR -d @$POSTTMP -A "$UA" https://myaccount.zen.co.uk/sign-in.aspx
}

#set the IP of the given admin page url
#fetches the html then uses zenasp.xsl to copy or modify the asp state (VIEWSTATE) params
#then form post back to the same admin page
function zenSetDynDns {
  XSLFN=zenasp.xsl
  POSTURL=$1

  #setup portal cookies + get html - firefox UA required otherwise a param doesn't get populated into the html
  curl -k -s -c $COOKIEJAR -b $COOKIEJAR -A "$UA" $POSTURL > $XMLFN

  #tidy up the html so xsltproc will process it
  tidy -q -numeric -asxhtml $XMLFN > $TIDYTMP 2> /dev/null

  #convert ipaddr to xsltproc params
  c=0
  PARAMSTR=""
  for IP in $(echo $IPADDR | tr "." "\n")
  do
    let c=c+1
    PARAMSTR="$PARAMSTR -param ip$c $IP"
  done
  #convert the html input tags to form post data
  xsltproc $PARAMSTR -param ttl $TTL $ZENDIR/$XSLFN $TIDYTMP > $POSTTMP

  #post it
  curl -k -s -d @$POSTTMP -c $COOKIEJAR -b $COOKIEJAR -A "$UA" $POSTURL | sed -n 's|.*\(Successfully.*effect\.\).*|\1|p'

  #TODO check for success message
}

#fetches the html of the domain list
function zenGetDomList {
  curl -k -s -c $COOKIEJAR -b $COOKIEJAR -A "$UA" $DOMLISTURL > $DOMLISTFN
  tidy -q -numeric -asxhtml $DOMLISTFN > $TIDYDOMLISTTMP 2> /dev/null
}

#extracts the relevant admin page url from the domain list html ready to used by zenSetDynDns
#uses getdomains.xsl to extract the url
#!!!must set the zen friendly name to the domains name e.g. sodnpoo.com!!!
function zenGetDomainURL {
  XSLFN=getdomains.xsl
  DOMAIN=$1
  PARAMSTR="-stringparam domain $DOMAIN"
  #convert the html input tags to form post data
  RETURN_URL=`xsltproc -novalid $PARAMSTR $ZENDIR/$XSLFN $TIDYDOMLISTTMP`
}

function cleanup {
  rm $COOKIEJAR $XMLFN $TIDYTMP $POSTTMP $DOMLISTFN $TIDYDOMLISTTMP 2> /dev/null
}

zenLogin      #login
zenGetDomList #get and save dom list

for D in $DOMAINS
do
  echo -n $D:
  CURRIPADDR=`dig +short $D`
  if [ "$IPADDR" != "$CURRIPADDR" ]; then
    #TODO check domains current IP and only update different from new one
    
    zenGetDomainURL $D
    if [ $RETURN_URL ]; then #if we couldn't find the url
      zenSetDynDns $RETURN_URL
    fi  
  fi
  
done
echo

cleanup

