$('#recurringCheck').change(function () {
    if (this.checked) {
        $('#recurring').removeClass('visually-hidden');
        $('#payday_recurring_every').prop('required', true);
    } else {
        $('#recurring').addClass('visually-hidden');
        $('#payday_recurring_every').prop('required', false);
    }
})