package user

// Validator defines the functions to validate User data.
type Validator interface {
	validate(user User) (ValidationErrors, error)
}

// ValidationErrors is a slice of ValidationError.
type ValidationErrors []*ValidationError

// ValidationError represents the detailed error message.
type ValidationError struct {
	Field   string
	Message string
}

// newValidator returns the default validator.
func newValidator(repository Repository) Validator {
	return &validator{
		repository: repository,
	}
}

// validator is the default implementation of Validator.
type validator struct {
	repository Repository
}

// validate validates the user data. If the input data fail to validate,
// ValidationErrors will be returned.
func (v *validator) validate(user User) (ValidationErrors, error) {
	var ve ValidationErrors

	if user.FirstName == nil {
		ve = append(ve, fieldMissingError("FirstName"))
	}
	if user.LastName == nil {
		ve = append(ve, fieldMissingError("LastName"))
	}

	isUnique, err := v.checkUniqueName(*user.FirstName)
	if err != nil {
		return nil, err
	}
	if !isUnique {
		ve = append(ve, nonUniqueValueError("firstname"))
	}

	return ve, nil
}

// checkUniqueName checks if the name already exists in redis.
func (v *validator) checkUniqueName(firstname string) (isUnique bool, err error) {
	c, err := v.repository.FindByName(firstname)

	if err != nil {
		return
	}

	isUnique = c == nil
	return
}

func fieldMissingError(field string) *ValidationError {
	return &ValidationError{field, "this field is required."}
}

func nonUniqueValueError(field string) *ValidationError {
	return &ValidationError{field, "the value already exists."}
}
