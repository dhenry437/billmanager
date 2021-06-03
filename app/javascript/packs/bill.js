$('#recurringCheck').change(function () {
    console.log('click');
    if (this.checked) {
        $('#recurring').removeClass('visually-hidden');
        $('#notRecurring').addClass('visually-hidden');
    } else {
        $('#recurring').addClass('visually-hidden');
        $('#notRecurring').removeClass('visually-hidden');
    }
})