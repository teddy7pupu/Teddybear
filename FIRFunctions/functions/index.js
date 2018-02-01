'use strict';

//Require
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const Q = require('q');
const mail = require('./utils/mail');

try {admin.initializeApp(functions.config().firebase);} catch(e) {}

//Database Reference
var db = admin.database();
var approvalRef = db.ref('Approval');
var leaveRef = db.ref('Leave');
var deptRef = db.ref('Department');
var staffRef = db.ref('Staff');

exports.onCreateLeave = functions.database.ref('Leave/{leaveId}')
  .onCreate(event => {
    if (!event.data.val()) {
      return console.log('No Leave data!');
    }

    const leave = event.data.val();
    const leaveId = leave.leaveId;
    var assignee = generateAssigneeApproval(leave);
    leaveRef.child(leaveId).update({
      approvals: [
        assignee
      ]
    });
  });

exports.onUpdateApproval = functions.database.ref('Approval/{aid}')
  .onUpdate(event => {
  if (!event.data.val()) {
    return console.log('No Approval data!');
  }

  const oldStatus = event.data.previous.child('status').val();
  const newStatus = event.data.child('status').val();
  const approval = event.data.val();
  const leaveId = approval.leaveId;
  leaveRef.child(leaveId).once('value').then(function(snap) {
    var leave = snap.val();
    console.log('[LEAVE]',leave);

    updateApproval(leave, approval);
    if (oldStatus == 0 && newStatus == 1) { //Accept
      if (leave.approvals.length == 1) { //Assignee -> Supervisor
        generateSupervisorApproval(leave, approval);
      }
      if (leave.approvals.length == 2) { //Supervisor -> Finish
        finishLeaveApply(leave);
      }
    }
    if (newStatus == 2) { //Reject
      rejectLeave(leave, approval);
    }
  });
})

exports.onRemoveLeave = functions.database.ref('Leave/{leaveId}')
  .onDelete(event => {
    const leave = event.data.previous.val();
    var approvals = leave.approvals
    approvals.forEach( function(approval) {
      approvalRef.child(approval.aid).remove();
    });

    queryStaff(leave.sid).then(function(staff) {
      queryStaff(leave.assigneeId).then(function(assignee) {
        mail.sendDeleteMail(staff, assignee, leave);
      })
    })
})

function generateAssigneeApproval(leave) {
  var newApprovalRef = approvalRef.push();
  const _aid = newApprovalRef.key;
  const _leaveId = leave.leaveId;
  const _sid = leave.assigneeId;
  var approval = {
    aid: _aid,
    leaveId: _leaveId,
    sid: _sid,
    status: 0
  };
  newApprovalRef.set(approval);
  queryStaff(leave.sid).then(function(staff) {
    queryStaff(_sid).then(function(assignee) {
      mail.sendApprovalMail(staff, assignee, leave);
    })
  })

  return approval;
}

function generateSupervisorApproval(leave, approval) {
  var newApprovalRef = approvalRef.push();
  const _aid = newApprovalRef.key;
  const _leaveId = leave.leaveId;
  const deptId = leave.departmentId;
  deptRef.child(deptId).once('value').then(function(snap) {
    var dept = snap.val();
    const _sid = dept.supervisor;
    var newApproval = {
      aid: _aid,
      leaveId: _leaveId,
      sid: _sid,
      status: 0
    };
    newApprovalRef.set(newApproval);

    var approvals = leave.approvals;
    approvals[0] = approval;
    approvals.push(newApproval);
    leaveRef.child(leave.leaveId).update({
      approvals: approvals
    });

    queryStaff(leave.sid).then(function(staff) {
      queryStaff(_sid).then(function(assignee) {
        mail.sendApprovalMail(staff, assignee, leave);
      })
    })
  });
}

function finishLeaveApply(leave) {
  queryStaff(leave.sid).then(function(staff) {
    queryAccount().then(function(account) {
      mail.sendFinishMail(staff, account, leave);
    })
  });
}

function rejectLeave(leave, approval) {
  queryStaff(leave.sid).then(function(staff) {
    queryStaff(approval.sid).then(function(assignee) {
      mail.sendRejectMail(staff, assignee, approval.message, leave);
    });
  });
}

function updateApproval(leave, approval) {
  var approvals = leave.approvals;
  var newApprovals = [];
  approvals.forEach( function(_approval) {
    if (_approval.aid == approval.aid) {
      newApprovals.push(approval);
    } else {
      newApprovals.push(_approval);
    }
  });
  leaveRef.child(leave.leaveId).update({
    approvals: newApprovals
  });
}

function queryStaff(staffId) {
  var deferred = Q.defer();
  staffRef.child(staffId).once('value').then(function(snap) {
    var staff = snap.val();
    if (!staff) {
      deferred.reject('No Data');
    } else {
      deferred.resolve(staff);
    }
  });
  return deferred.promise;
}

function queryAccount() {
  var deferred = Q.defer();
  staffRef.orderByChild("role").equalTo(3).on("child_added", function(snap) {
    var staff = snap.val();
    if (!staff) {
      deferred.reject('No Data');
    } else {
      deferred.resolve(staff);
    }
  });
  return deferred.promise;
}
