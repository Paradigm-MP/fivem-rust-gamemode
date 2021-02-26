// Create placeholder OOF object if it does not exist (for developing in a browser)
const oof = typeof OOF != 'undefined' ? OOF : {
    Subscribe: () => {},
    CallEvent: () => {}
};

export default oof