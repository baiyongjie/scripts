# -*- coding: UTF-8 -*-
import datetime
import smtplib
import email.mime.multipart
import email.mime.text
from email.mime.application import MIMEApplication

nowDay = datetime.datetime.now().strftime('%Y%m%d')
def send_email(smtpHost, sendAddr, password, toAddr, ccAddr, subject='', content=''):
    msg = email.mime.multipart.MIMEMultipart()
    msg['from'] = sendAddr
    msg['to'] = ', '.join(toAddr)
    msg['cc'] = ', '.join(ccAddr)
    msg['subject'] = subject
    content = content
    txt = email.mime.text.MIMEText(content, 'plain', 'utf-8')
    msg.attach(txt)


    # # 添加附件，E:\vcode.png
    # part = MIMEApplication(open(r'E:\vcode.png', 'rb').read())
    # part.add_header('Content-Disposition', 'attachment', filename="vcode.png")
    # msg.attach(part)


    smtp = smtplib.SMTP()
    smtp.connect(smtpHost, '25')
    smtp.login(sendAddr, password)
    smtp.sendmail(sendAddr, toAddr + ccAddr, str(msg))
    print("发送成功！")
    smtp.quit()

if __name__=="__main__":
    try:
        toAddr = ['misterbyj@163.com'] # 收件人地址
        ccAddr = ['15600970600@163.com'] #抄送人地址
        subject = ' email title'
        content = '  email body '
        send_email('smtp.163.com', '15600970600@163.com', 'Password', toAddr, ccAddr, subject, content)
    except Exception as err:
        print(err)
