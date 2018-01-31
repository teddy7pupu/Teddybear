//Require
const functions = require('firebase-functions');
const nodemailer = require('nodemailer');
const moment = require('moment');

//TIME Configure
const beginSection = [' 10:00', ' 15:00'];
const endSection = [' 14:00', ' 19:00'];

//EMAIL Function
const gmailEmail = functions.config().gmail.email;
const gmailPassword = functions.config().gmail.password;
const mailTransport = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: gmailEmail,
    pass: gmailPassword
  }
});

exports.sendApprovalMail = function(staff, assignee, leave) {
  let email = staff.email;
  const mailOptions = {
    from: `teddyBear <noreply@appmaster.cc>`,
    to: email
  };

  let applyDate = moment.unix(leave.applyTime).add(8, 'h');
  let beginDate = moment.unix(leave.startTime).add(8, 'h');
  let endDate = moment.unix(leave.endTime).add(8, 'h');
  mailOptions.subject = `[teddyBear] ` + staff.name + `的` + leave.type + `申請`;
  let body = `Hi ` + assignee.name + `,`;
  body += `\n\n` + staff.name + ` 提出了一張假單申請需請您簽核，請至teddyBear登入後進行回覆。`
  body += `\n假單資訊如下：`
  body += `\n假別：` + leave.type;
  body += `\n請假區間：` + beginDate.format('YYYY-MM-DD') + beginSection[leave.startPeriod] + `到` + endDate.format('YYYY-MM-DD') + endSection[leave.endPeriod];
  body += `\n請假事由：` + leave.message;
  body += `\n代理人：` + assignee.name;
  body += `\n\n感謝您的合作 :)`;
  mailOptions.text = body;
  return mailTransport.sendMail(mailOptions).then(() => {
    console.log('Mail sent: ', email);
  });
}

exports.sendDeleteMail = function(staff, assignee, leave) {
  let email = staff.email;
  const mailOptions = {
    from: `teddyBear <noreply@appmaster.cc>`,
    to: email
  };

  let applyDate = moment.unix(leave.applyTime).add(8, 'h');
  let beginDate = moment.unix(leave.startTime).add(8, 'h');
  let endDate = moment.unix(leave.endTime).add(8, 'h');
  mailOptions.subject = `[teddyBear] ` + staff.name + `的` + leave.type + `申請已刪除`;
  let body = `Hi ` + staff.name + `,`;
  body += `\n\n您已將` + applyDate.format('YYYY-MM-DD hh:mm:ss A') + `申請的假單刪除了`;
  body += `\n假單資訊如下：`
  body += `\n假別：` + leave.type;
  body += `\n請假區間：` + beginDate.format('YYYY-MM-DD') + beginSection[leave.startPeriod] + `到` + endDate.format('YYYY-MM-DD') + endSection[leave.endPeriod];
  body += `\n請假事由：` + leave.message;
  body += `\n代理人：` + assignee.name;
  body += `\n\n感謝您的合作 :)`;
  mailOptions.text = body;
  return mailTransport.sendMail(mailOptions).then(() => {
    console.log('Mail sent: ', email);
  });
}

exports.sendFinishMail = function(staff, account, leave) {
  let email = staff.email;
  const mailOptions = {
    from: `teddyBear <noreply@appmaster.cc>`,
    to: email,
    cc: account.email
  };

  let applyDate = moment.unix(leave.applyTime).add(8, 'h');
  let beginDate = moment.unix(leave.startTime).add(8, 'h');
  let endDate = moment.unix(leave.endTime).add(8, 'h');
  mailOptions.subject = `[teddyBear] ` + staff.name + `的` + leave.type + `假單申請已核准`;
  let body = `Hi ` + staff.name + `,`;
  body += `\n\n您在` + applyDate.format('YYYY-MM-DD hh:mm:ss A') + `申請的假單已核准`;
  body += `\n假單資訊如下：`
  body += `\n假別：` + leave.type;
  body += `\n請假區間：` + beginDate.format('YYYY-MM-DD') + beginSection[leave.startPeriod] + `到` + endDate.format('YYYY-MM-DD') + endSection[leave.endPeriod];
  body += `\n請假事由：` + leave.message;
  body += `\n\n感謝您的合作 :)`;
  mailOptions.text = body;
  return mailTransport.sendMail(mailOptions).then(() => {
    console.log('Mail sent: ', email, ';', account.email);
  });
}

exports.sendRejectMail = function(staff, assignee, message, leave) {
  let email = staff.email;
  const mailOptions = {
    from: `teddyBear <noreply@appmaster.cc>`,
    to: email
  };
  let applyDate = moment.unix(leave.applyTime).add(8, 'h');
  let beginDate = moment.unix(leave.startTime).add(8, 'h');
  let endDate = moment.unix(leave.endTime).add(8, 'h');
  mailOptions.subject = `[teddyBear] ` + staff.name + `的` + leave.type + `假單申請已核准`;
  let body = `Hi ` + staff.name + `,`;
  body += `\n\n您在` + applyDate.format('YYYY-MM-DD hh:mm:ss A') + `申請的假單已被` + assignee.name + `拒絕`;
  body += `\n簽核回應：` + message;
  body += `\n\n假單資訊如下：`
  body += `\n假別：` + leave.type;
  body += `\n請假區間：` + beginDate.format('YYYY-MM-DD') + beginSection[leave.startPeriod] + `到` + endDate.format('YYYY-MM-DD') + endSection[leave.endPeriod];
  body += `\n請假事由：` + leave.message;
  body += `\n\n感謝您的合作 :)`;
  mailOptions.text = body;
  return mailTransport.sendMail(mailOptions).then(() => {
    console.log('Mail sent: ', email);
  });
}
