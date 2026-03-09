(module
  (import "env" "log_f64" (func $log_f64 (param f64)))
  (import "env" "log_vec3" (func $log_vec3 (param f64 f64 f64)))
  (func (export "main")
    f64.const 20
    call $log_f64
  )
)

