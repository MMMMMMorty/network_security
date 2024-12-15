# Email Server

## Purpose of the Lab

The **purpose of the lab** is to provide practical experience in setting up, configuring, and managing an email server environment using multiple Mail Transfer Agents (MTAs) and related software. It aims to give participants hands-on practice with the following key objectives:

## Objectives of the Lab:

1. **Understanding Email Server Configuration**:
   - Learn how to configure MTAs (like Postfix and Exim4) to handle local and relay mail.
   - Adjust key configuration settings such as `mydestination`, `mynetworks`, and `smtpd_etrn_restrictions`.

2. **Network and DNS Configuration**:
   - Modify `/etc/hosts` files to configure hostnames and IP addresses.
   - Understand and configure MX records in DNS to manage mail routing effectively.

3. **Security Best Practices**:
   - Secure SMTP ports (25, 587) and utilize `ufw` (Uncomplicated Firewall) to control traffic.
   - Implement command restrictions like disabling VRFY to prevent abuse by spammers.

4. **Email Delivery and Filtering**:
   - Test email delivery from one MTA (lab2) to another (lab1) to ensure proper operation of email transmission.
   - Use tools like `mailutils`, `mail`, and `procmail` to simulate and analyze the flow of emails.
   - Set up `SpamAssassin` to filter spam, understand its role in email security, and configure it to move flagged spam messages.

5. **Logging and Monitoring**:
   - Monitor SMTP logs and email headers to understand how emails are processed.
   - Analyze log messages and headers to diagnose email issues and understand the flow of communication between email servers.

6. **Hands-on Problem-Solving**:
   - Troubleshoot common issues that arise in email server setup, such as misconfigured MTAs, incorrect MX records, and spam filtering errors.
   - Experiment with different configurations to observe their effects on email behavior and security.

## 1 Preparation

During this assignment you will need two hosts (lab1 and lab2). Stop any daemons that might be listening on the default SMTP port.

### 1.1 Add the IPv4 addresses and aliases of lab1 and lab2 on both computers to the /etc/hosts file

    sudo echo "192.168.1.1 lab1" | sudo tee -a /etc/hosts

    sudo echo "192.168.1.2 lab2" | sudo tee -a /etc/hosts

## 2 Installing software and Configuring postfix and exim4

Installing mailutils on lab1

    #lab1
    sudo apt install mailutils

    sudo vim /etc/postfix/main.cf

### 2.1 Configure the postfix configuration file main.cf to fill the requirements above

main.cf is

    myhostname = lab1.kyla.fi
    mydestination = $myhostname, lab1, localhost.localdomain, lab2, localhost
    mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 192.168.1.0/24

    sudo postfix check

    sudo postfix reload

    #make sure SMTP 25 port is open
    sudo ufw enable

    sudo ufw app list

    sudo ufw allow OpenSSH

    sudo ufw allow Postfix

    sudo ufw allow 'Postfix SMTPS'
    
    sudo ufw allow 'Postfix Submission'

    #lab2
    sudo apt install telnetd -y


    sudo ufw allow 25
    sudo ufw allow 587
    sudo ufw reload

    sudo systemctl status inetd

    telnet lab1 25

### What is purpose of the main.cf setting "mydestination"?

The mydestination parameter specifies what domains this machine will deliver locally, instead of forwarding to another machine. The default is to receive mail for the machine itself.

### 2.3 Why is it a really bad idea to set mynetworks broader than necessary (e.g. to 0.0.0.0/0)?

It means everyone can send the email to lab1, which is unsafe. lab1 is UA, it should receive the email just from MTA(lab2).

### 2.4 What is the idea behind the ETRN and VRFY verbs? How can a malicious party misuse the commands?

    sudo vim /etc/postfix/main.cf

    smtpd_etrn_restrictions = reject
    
    disable_vrfy_command = yes

    postfix reload

    postconf | grep -i vrfy

VRFY is used to verify whether a **mailbox** in the argument exists on the local host.

EXPN is used to verify whether a **mailing list** in the argument exists on the local host. 

VRFY and EXPN implement SMTP authentication.  Also, they are useful to perform an internal audit of the server. **On the other hand, these commands are considered a security risk. Spammers can use them to harvest valid email addresses from the server.** Therefore, messaging systems either install corresponding protections or disable the commands. 

### 2.5 Configure exim4 on lab2 to handle local emails and send all the rest to lab1. After you have configured postfix and exim4 you should be able to send mail from lab2 to lab1, but not vice versa. Use the standard debian package reconfiguration tool dpkg-reconfigure(8) to configure exim4.

    sudo apt install exim4

    sudo dpkg-reconfigure exim4-config

    sudo vim /etc/exim4/update-exim4.conf.conf

dc_relay_nets are used to add the IP address of the client/servers

dc_relay_domains are used to add the domain names of the client/servers

    dc_eximconfig_configtype='smarthost'
    dc_other_hostnames='lab2'
    dc_local_interfaces='127.0.0.1 ; ::1'
    dc_readhost=''
    dc_relay_domains=''
    dc_minimaldns='false'
    dc_relay_nets='192.168.1.1'
    dc_smarthost='lab1'
    CFILEMODE='644'
    dc_use_split_config='false'
    dc_hide_mailname='false'
    dc_mailname_in_oh='true'
    dc_localdelivery='mail_spool'

    sudo update-exim4.conf

    sudo systemctl restart exim4

See https://www.tutorialspoint.com/configure-exim4-smtp-relay-server

## 3 Sending email

    #lab1
    sudo adduser vagrant mail
    sudo touch /var/mail/$USER
    sudo chown $USER:mail /var/mail/$USER
    sudo chmod 750 /var/mail/$USER

    #lab2
    mail -s "This is the subject2" vagrant@lab1 <<< 'This is the message'

    #lab1
    mailx/mail

### 3.1 Explain shortly the incoming mail log messages

    sudo tail /var/log/mail.log

    Jan 30 14:36:27 lab1 postfix/smtpd[66022]: connect from lab2[192.168.1.2]
    Jan 30 14:36:27 lab1 postfix/smtpd[66022]: 3A5E23F57C: client=lab2[192.168.1.2]
    Jan 30 14:36:27 lab1 postfix/cleanup[66025]: 3A5E23F57C: message-id=<E1pMVGg-000IWo-Lr@lab2>
    Jan 30 14:36:27 lab1 postfix/qmgr[61968]: 3A5E23F57C: from=<vagrant@lab2>, size=548, nrcpt=1 (queue active) ##accepted
    Jan 30 14:36:27 lab1 postfix/local[66026]: 3A5E23F57C: to=<vagrant@lab1>, relay=local, delay=0, delays=0/0/0/0, dsn=2.0.0, status=sent (delivered to mailbox)
    Jan 30 14:36:27 lab1 postfix/qmgr[61968]: 3A5E23F57C: removed
    Jan 30 14:36:27 lab1 postfix/smtpd[66022]: disconnect from lab2[192.168.1.2] ehlo=2 starttls=1 mail=1 rcpt=1 bdat=1 quit=1 commands=7

### 3.2 Explain shortly the email headers. At what point is each header added?

    Return-Path: <vagrant@lab2>
    X-Original-To: vagrant@lab1
    Delivered-To: vagrant@lab1
    Received: from lab2 (lab2 [192.168.1.2])
            by lab1.kyla.fi (Postfix) with ESMTPS id 3A5E23F57C
            for <vagrant@lab1>; Mon, 30 Jan 2023 14:36:27 +0000 (UTC)
    Received: from vagrant by lab2 with local (Exim 4.93)
            (envelope-from <vagrant@lab2>)
            id 1pMVGg-000IWo-Lr
            for vagrant@lab1; Mon, 30 Jan 2023 14:36:22 +0000

    Subject: This is the subject line
    To: <vagrant@lab1>
    X-Mailer: mail (GNU Mailutils 3.7)
    Message-Id: <E1pMVGg-000IWo-Lr@lab2>
    From: vagrant@lab2
    Date: Mon, 30 Jan 2023 14:36:22 +0000

Return-Path

If the message is rejected, it will be sent back to the email address listed here, which is also the sender of the message.

X-Original-To

The email address listed here is the original recipient of the email that was received.

Delivered-To

The email user, that is listed to the left of the '@' symbol, is the user ID of the recipient email address with its specific host. The server listed (to the right of the ‘@’ symbol) is your Bluehost mail server that received this particular message.

Received

There is a 'Received by' and 'Received from' details listed on the headers. When checking your headers, the 'Received by' is indicating that it was received by the IP or server name when the message was originally sent. The 'Received from' would be the server that sent or relayed the email at any specific point in the header.

Two kinds of headers

Partial Headers:
The partial headers are what you normally look at in your emails. These are the most important to your daily tasks. It contains the headers such as the From Address, To Address, Subject, Date and Time, Reply-To Address, CC, and BCC.

Full Headers:
The full headers are a little bit more technical information than you check on when you want to know the comprehensive details of an email. Occasionally, we will need those complete headers in order to solve a problem.

In an email, the body (content text) is always preceded by header lines that identify routing information of the message, including the sender, recipient, date and subject. Some headers are mandatory, such as the From, To, and Date headers. Others are optional, but very commonly used, such as Subject and CC.

Other headers include the sending time stamps and the receiving time stamps of all mail transfer agents that have received and sent the message. In other words, any time a message is transferred from one node to another the message is date/time stamped by a mail transfer agent (MTA). This date/time stamp, like From, To, and Subject, becomes one of the many headers that precede the body of an email.


## 4 Configuring procmail and spamassassin

    sudo apt-get update -y

    sudo apt-get install -y procmail    

    sudo apt-get install -y spamassassin    

    sudo touch /etc/procmailrc

    sudo vim /etc/procmailrc

    :0fw
    | /usr/bin/spamassassin

    sudo vim /etc/postfix/main.cf

    #add
    mailbox_command =/usr/bin/procmail -a "lab1"

    sudo postfix reload

    #add this line to /etc/default/spamassassin
    CRON=1

    ENABLED =1 is not supported anymore

Now it change to

    sudo update-rc.d spamassassin enable

    sudo systemctl enable spamassassin.service

    sudo systemctl start spamassassin.service

    sudo systemctl restart postfix.service

The added header of spam

    X-Spam-Checker-Version: SpamAssassin 3.4.4 (2020-01-24) on lab1
    X-Spam-Level:
    X-Spam-Status: No, score=-0.9 required=5.0 tests=ALL_TRUSTED,TO_MALFORMED
            autolearn=no autolearn_force=no version=3.4.4

Pattern

    :0 [flags] [: lockfile-name ]
    * [ condition_1_special-condition-character condition_1_regular_expression ]
    * [ condition_2_special-condition-character condition-2_regular_expression ]
    * [ condition_N_special-condition-character condition-N_regular_expression ]
            special-action-character
            action-to-perform

Add this to the /etc/procmailrc

    #"If any line in the headers starts with 'X-Spam-Flag: YES', put it in the file spam in my home directory."
    :0:
    * ^X-Spam-Flag: YES
    $HOME/spam

    :0c:
    * ^(Subject).*cs-e4160
    $HOME/cs-e4160

    sudo adduser testuser1
    sudo touch /var/mail/testuser1
    #add to mail group, touch mailbox, and chmod
    
    sudo touch /home/vagrant/.procmailrc
    sudo vim /home/vagrant/.procmailrc

    #if add this to the /etc/procmailrc, it will have a permission bug
    :0c:
    * ^(From|Cc|To|Subject).*cs-e4160
    !testuser1

    # another solutioin
    :0cH:
    * ^(From|Cc|To|Subject).*cs-e4160
    !testuser1

    sudo postfix reload

### 4.1 How can you automatically filter spam messages to a different folder using procmail? Demonstrate by sending a message that gets flagged as spam.

    echo "This is an email test, XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X" | mail -s "cs-e4160" vagrant@lab1

### 4.2 Demonstrate the filter rules created for messages with [cs-e4160] in the subject field by sending a message from lab2 to <user>@lab1 using the header

    echo "This is an email test" | mail -s "cs-e4160" vagrant@lab1
    cat /var/mail/testuser1

### 4.3 Explain briefly the additional email headers (compare with 3.2)

    From vagrant@lab1.kyla.fi  Tue Jan 31 10:25:18 2023
    Return-Path: <vagrant@lab1.kyla.fi>

    X-Spam-Checker-Version: SpamAssassin 3.4.4 (2020-01-24) on lab1
    X-Spam-Level:
    X-Spam-Status: No, score=0.1 required=5.0 tests=ALL_TRUSTED,

    HEADER_FROM_DIFFERENT_DOMAINS,TO_MALFORMED autolearn=no
    autolearn_force=no version=3.4.4

    X-Original-To: testuser1
    Delivered-To: testuser1@lab1.kyla.fi
    Received: by lab1.kyla.fi (Postfix, from userid 1000)
    id 5A71247359; Tue, 31 Jan 2023 10:25:18 +0000 (UTC)


    X-Original-To: vagrant@lab1
    Delivered-To: vagrant@lab1
    Received: from lab2 (lab2 [192.168.1.2])
    by lab1.kyla.fi (Postfix) with ESMTPS id 9366347303
    for <vagrant@lab1>; Tue, 31 Jan 2023 10:25:17 +0000 (UTC)
    Received: from vagrant by lab2 with local (Exim 4.93)
    (envelope-from <vagrant@lab2>)
    id 1pMnoj-000NMv-QG
    for vagrant@lab1; Tue, 31 Jan 2023 10:24:45 +0000
    Subject: cs-e4160
    To: <vagrant@lab1>
    X-Mailer: mail (GNU Mailutils 3.7)
    Message-Id: <E1pMnoj-000NMv-QG@lab2>
    From: vagrant@lab2
    Date: Tue, 31 Jan 2023 10:24:45 +0000

    This is an email test

## 5 E-mail servers and DNS

### 5.1 What information is stored in MX records in the DNS system?

A DNS 'mail exchange' (MX) record directs email to a mail server. The MX record indicates how email messages should be routed in accordance with the Simple Mail Transfer Protocol (SMTP, the standard protocol for all email). Like CNAME records, an MX record must always point to another domain.

    Domain          TTL   Class    Type  Priority      Host (mail exchanger)
    example.com.    1936    IN  MX  10         onemail.example.com.
    example.com.    1936    IN  MX  10         twomail.example.com.

TTL

The time-to-live in seconds. It specifies how long a resolver is supposed to cache or remember the DNS query before the query expires and a new one needs to be done.

Record Class

Mainly 3 classes of DNS records exist:

IN (Internet) - default and generally what internet uses.

CH (Chaosnet) - used for querying DNS server versions.

HS (Hesiod) - uses DNS functionality to provide access to databases of information that change infrequently.

Record Type

The record format is defined using this field. Common record types are A, AAAA, CNAME, CAA, TXT etc. In the case of an MX record, the record type is MX.

### 5.2 Explain briefly two ways to make redundant email servers using multiple email servers and the DNS system. Name at least two reasons why you would have multiple email servers for a single domain?

1. Solution 1: Forwarding to two email addresses

    You forward all of the mail addressed to <anyone@yourdomain.com> to two different external email accounts.

    How to do it

    At your domain registrar, go into their control panel and set up "catch-all" email forwarding to two different external email addresses (these can be anywhere, including at your ISP or a provider such as Yahoo!, Hotmail, or Gmail).

2. Solution 2: Adding a "queue and store" email backup service

    A "queue and store" email backup service collects and stores emails addressed to <anyone@yourdomain.com> whenever your receiving email server is unavailable. The backup service periodically tests to see if your receiving server is back up and sends the collected emails on when your receiving server is available.

    How to do it

    Sign up for "queue and store" email backup service at the provider of your choice. Then go to the provider that hosts your DNS records and add an MX record for the backup email service, per the instructions given by the "queue and store" email backup service. Make sure the "priority number" is HIGHER than the number associated with the MX record of your primary email server.

3. Solution 3: Adding an additional email server

    You add an additional email server and set it to forward your emails.

Two reasons:

It is possible to use multiple mail servers for the same domain name, but the way it is done depends on the type of configuration you have. This is referred to as **Shared SMTP Namespace**

One way to use multiple mail servers for the same domain name is to set up a **load balancer**. A load balancer is a device that distributes incoming email traffic across multiple mail servers, ensuring that each server is being used efficiently and minimizing the risk of a single server becoming overwhelmed.

Another way is to set up **a mail server cluster**, which is a group of servers that work together to handle incoming email traffic for a specific domain. This allows you to have multiple servers available to handle incoming mail in case one of the servers goes down.

It's worth noting that you will need to configure your DNS records (MX records) to point to multiple mail servers, and you will also need to make sure that all of the servers are properly configured to work together.

