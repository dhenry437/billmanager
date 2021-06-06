$('#recurringCheck').change(function () {
    if (this.checked) {
        $('#recurring').removeClass('visually-hidden');
    } else {
        $('#recurring').addClass('visually-hidden');
    }
})