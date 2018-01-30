const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

var db = admin.database();
var approvalRef = db.ref('Approval');
var leaveRef = db.ref('Leave');
var deptRef = db.ref('Department');

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

    if (oldStatus == 0 && newStatus == 1) { //Accept
      if (leave.approvals.length == 1) { //Assignee -> Supervisor
        generateSupervisorApproval(leave);
      }
      if (leave.approvals.length == 2) { //Supervisor -> Finish

      }
    }
    if (newStatus == 2) { //Reject
      //Send notification to related people.
    }
    updateApproval(leave, approval)
  });
})

exports.onRemoveLeave = functions.database.ref('Leave/{leaveId}')
  .onDelete(event => {
    const leave = event.data.previous.val();
    var approvals = leave.approvals
    approvals.forEach( function(aid) {
      approvalRef.child(aid).remove();
    });
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
  return approval;
}

function generateSupervisorApproval(leave) {
  var newApprovalRef = approvalRef.push();
  const _aid = newApprovalRef.key;
  const _leaveId = leave.leaveId;
  const deptId = leave.departmentId;
  deptRef.child(deptId).once('value').then(function(snap) {
    var dept = snap.val();
    const _sid = dept.supervisor;
    var approval = {
      aid: _aid,
      leaveId: _leaveId,
      sid: _sid,
      status: 0
    };
    newApprovalRef.set(approval);
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
