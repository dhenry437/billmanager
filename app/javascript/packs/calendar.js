// Redirect to add new bill on calendar cell click
// $('.day').click(function () {
//     window.location.href = `/bills/add?date=${$(this).data('date')}`
// });
$('.day').click(function () {
    // window.location.href = `/bills/add?date=${$(this).data('date')}`
    window.location.href = getNewUrl(window.location.href, $(this).data('date'))
});

function getNewUrl(oldUrl, data_val) {
    // var data_val = "new_data";
    var newUrl;
    if (/[?&]date\s*=/.test(oldUrl)) {
        newUrl = oldUrl.replace(/(?:([?&])date\s*=[^?&]*)/, "$1date=" + data_val);
    } else if (/\?/.test(oldUrl)) {
        newUrl = oldUrl + "&date=" + data_val;
    } else {
        newUrl = oldUrl + "?date=" + data_val;
    }
    console.log(oldUrl + "\n...becomes...\n" + newUrl);
    return newUrl
}