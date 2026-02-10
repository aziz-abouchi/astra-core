// grammar.js — Heaven HM (avec champs pour queries)
module.exports = grammar({
  name: 'heaven',
  // Conflicts minimisés : ne garder que si nécessaire
  conflicts: $ => [ ],
  extras: $ => [/\s+/, $.comment],
  rules: {
    source_file: $ => repeat($.top_decl),
    comment: _ => token(seq('--', /.*/)),

    // Top-level statements
    top_decl: $ => choice($.data_decl, $.type_signature_top_stmt, $.value_definition_top_stmt),

    // data Type a = Con1 T | Con2 U
    data_decl: $ => seq(
      'data',
      field('name', $.type_constructor),
      repeat($.type_var),
      '=',
      field('ctors', seq($.constructor, repeat(seq('|', $.constructor))))
    ),

    constructor: $ => seq(
      field('name', $.type_constructor),
      repeat(field('arg', $.type_atom))
    ),

    type_signature_top_stmt: $ => seq($.type_signature, ';'),
    type_signature_stmt: $ => seq($.type_signature, ';'),
    type_signature: $ => seq(field('name', $.identifier), ':', field('typ', $.type)),

    value_definition_top_stmt: $ => seq(field('name', $.identifier), repeat($.pattern), '=', $.expression, ';'),

    // Patterns (HM)
    pattern_app: $ => prec.left(1, seq($.type_constructor, repeat($.pattern_atom))),
    pattern_atom: $ => choice($.identifier, seq('(', $.pattern, ')'), $.pattern_record),
    pattern_record: $ => seq('{', optional(seq($.pattern_binding, repeat(seq(';', $.pattern_binding)), optional(';'))), '}'),
    pattern_binding: $ => seq(field('field', $.identifier), '=', field('p', $.pattern)),
    pattern: $ => choice($.pattern_app, $.pattern_record, $.identifier, seq('(', $.pattern, ')')),

    param_pattern: $ => choice(
      $.identifier,
      $.pattern_record
    ),
    // Blocks & statements
    block: $ => seq('{', repeat($.block_statement), '}'),
    block_statement: $ => choice($.value_definition_stmt, $.type_signature_stmt, $.expr_stmt),
    value_definition_stmt: $ => seq(field('name', $.identifier), repeat($.param_pattern), '=', $.expression, ';'),
    expr_stmt: $ => seq($.expression, optional(';')),

    // Types (HM)
    type: $ => prec.right(1, seq($.type_application, repeat(seq('->', $.type)))),
    type_application: $ => prec.left(seq($.type_base, repeat($.type_base))),
    type_base: $ => choice($.type_parenthesized, $.type_atom, $.type_error_union),
    type_parenthesized: $ => seq('(', $.type, ')'),
    type_atom: $ => choice($.type_constructor, $.type_var, $.type_slice, $.type_optional, $.type_array, $.type_ptr, $.type_record),
    type_slice: $ => prec(1, choice(seq('Slice', $.type_base), seq('[', $.type, ']'))),
    type_optional: $ => choice(seq('?', $.type_base), seq('Option', $.type_base)),
    type_error_union: $ => prec.right(3, seq($.type_base, '!', $.type)),
    type_array: $ => seq('[', $.number, ']', $.type_base),
    type_ptr:   $ => seq('*', $.type_base),
    type_record: $ => seq('{', optional(seq($.record_field, repeat(seq(';', $.record_field)), optional(';'))), '}'),
    record_field: $ => seq(field('name', $.identifier), ':', field('typ', $.type)),

    // Expressions
    expression: $ => prec(2, choice(
      $.lambda, $.if_expr, $.let_in, $.case_expr, $.try_expr, $.catch_expr,
      $.comptime_block, $.infix_expr, $.app_expr, $.term
    )),
    lambda: $ => choice(
      seq('\\', repeat1($.identifier), '->', $.expression),
      seq('fun', repeat1($.identifier), '->', $.expression)
    ),
    if_expr:   $ => seq('if',  $.expression, 'then', $.expression, 'else', $.expression),
    let_in:    $ => seq('let', $.identifier, '=', $.expression, 'in',   $.expression),

    // case ... of branch (';' branch)* ; branches séparées par ';' sans ';' final
    case_branch: $ => seq($.pattern, '->', $.expression),
    case_expr: $ => prec.right(1, seq('case', $.expression, 'of', $.case_branch, repeat(seq(';', $.case_branch)))),

    // try/catch robuste
    try_expr: $ => seq('try', $.expression),
    catch_expr: $ => prec.right(3, seq($.try_expr, 'catch', $.expression)),

    comptime_block: $ => seq('comptime', $.block),

    infix_expr: $ => prec.left(seq($.app_expr, repeat1(seq(choice('+','-','*','/','==','!=','<','<=','>','>='), $.app_expr)))),
    app_expr: $ => prec.left(1, seq($.term, repeat1($.term))),

    term: $ => prec(2, choice($.parenthesized, $.field_expr, $.index_expr, $.literal, $.identifier)),
    parenthesized: $ => seq('(', $.expression, ')'),
    field_expr: $ => seq($.term, '.', $.identifier),
    index_expr: $ => seq($.term, '[', $.expression, ']'),

    // Literals & atoms
    identifier:       _ => /[a-z_][A-Za-z0-9_]*/,
    type_constructor: _ => /[A-Z][A-Za-z0-9_]*/,
    type_var:         _ => /[a-z][A-Za-z0-9_]*/,
    number:           _ => /[0-9]+/,
    string: _ =>
      token(seq(
        '"',
        repeat(choice(/[^"\\\n]/, /\\./)),
        '"'
      )),
    bool:             _ => choice('true','false'),
    null:             _ => 'null',
    literal: $ => choice($.number, $.string, $.bool, $.null),
  }
});
