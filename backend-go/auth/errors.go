package auth

import "errors"

// Authentication errors are deliberately grouped into a few stable internal
// categories. Tests and middleware can inspect them with errors.Is without
// depending on detailed errors returned by the JWT library.
//
// These messages are not API responses. The HTTP middleware must always return
// a generic 401 "unauthorized" response so it does not reveal whether a token
// was expired, malformed, signed by the wrong key, or otherwise invalid. The
// raw bearer token must never be attached to or logged with these errors.
var (
	// ErrMalformedToken means the value does not have a usable JWT structure,
	// such as an empty, oversized, or incorrectly encoded token.
	ErrMalformedToken = errors.New("malformed token")

	// ErrInvalidToken means the JWT structure was readable but authentication
	// failed, for example because of its signature, algorithm, issuer, audience,
	// key ID, required claims, or subject UUID.
	ErrInvalidToken = errors.New("invalid token")

	// ErrExpiredToken is kept separate so tests and internal metrics can
	// distinguish ordinary session expiry without exposing that detail publicly.
	ErrExpiredToken = errors.New("expired token")
)
