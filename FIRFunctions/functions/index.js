const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

var db = admin.database();
var approvalRef = db.ref("Approval");

exports.onCreateLeave = functions.database.ref('Leave/{leaveId}')
  .onCreate(event => {
    if (!event.data.val()) {
      return console.log('No Leave data!');
    }

    const leave = event.data.val();
    var assignee = generateAssigneeApproval(leave);
    // var supervisor = generateSupervisorApproval(leave);
    console.log("[Approval]:",assignee);

    var leaveRef = event.data.ref;
    leaveRef.update({
      approvals: [
        assignee
      ]
    });
  });


function generateAssigneeApproval(leave) {
  var newApprovalRef = approvalRef.push();
  const _aid = newApprovalRef.key;
  const _leaveId = leave.leaveId;
  const _sid = leave.assigneeId;
  newApprovalRef.set({
    aid: _aid,
    leaveId: _leaveId,
    sid: _sid,
    status: 0
  });
  return _aid;
}

function generateSupervisorApproval(leave) {
}
