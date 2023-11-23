local utils = require('complexity.utils')
local config = require('complexity.config')

local M = {}

-- complexity.nvim
-- Neovim plugin that highlights Cyclomatic Complexity

-- (lexical_declaration) @captures
local function_queriess = [[
  (function) @captures
  (arrow_function) @captures
  (method_definition) @captures
  (function_declaration) @captures
  (generator_function_declaration) @captures
]]

local function recurse_tree(node)
  local nested_count = 0

  for _, child_node in ipairs(node:named_children()) do
    if child_node:type() == "statement_block" then
      for _, body in ipairs(child_node:named_children()) do
        local child_type = body:type()

        if
            child_type == "lexical_declaration"
            or child_type == "catch_clause"
            or child_type == "switch_case"
            or child_type == "switch_default"

            or child_type == "yield_expression"
            or child_type == "binary_expression"
            or child_type == "member_expression"
            or child_type == "logical_expression"
            or child_type == "conditional_expression"
        then
          nested_count = nested_count + 1
          -- utils.setVirtualText(ns_cc, body:start(), "+1", "cc", nil) -- signs.info.highlightGroup)
        end


        if
            child_type == "if_statement"
            or child_type == "do_statement"
            or child_type == "for_statement"
            or child_type == "try_statement"
            or child_type == "case_statement"
            or child_type == "while_statement"
            or child_type == "throw_statement"
            or child_type == "return_statement"
            or child_type == "for_in_statement"
            or child_type == "switch_statement"
            or child_type == "default_statement"
            or child_type == "expression_statement"
        then
          nested_count = nested_count + recurse_tree(body)
          -- utils.setVirtualText(ns_cc, body:start(), "+1", "cc", nil) -- signs.info.highlightGroup)
        end
      end
    end
  end

  return nested_count
end

function M.show(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not utils.enabled_when_supprted_filetype(config.supported_filetypes, bufnr) then
    return utils.noop
  end

  local _, parsed, root = utils.query_buffer(bufnr, function_queriess)
  if not parsed then
    print("Error: buffer does not have a TypeScript or JavaScript parser")
    return utils.noop
  end

  for _, match in parsed:iter_matches(root, bufnr) do
    local node = match[1]
    local complexity = 1

    for _, child_node in ipairs(node:named_children()) do
      if child_node:type() == "statement_block" then
        for _, body in ipairs(child_node:named_children()) do
          local child_type = body:type()

          if
              child_type == "lexical_declaration"
              or child_type == "catch_clause"
              or child_type == "switch_case"
              or child_type == "switch_default"

              or child_type == "yield_expression"
              or child_type == "member_expression"
              or child_type == "binary_expression"
              or child_type == "logical_expression"
              or child_type == "conditional_expression"

              or child_type == "if_statement"
              or child_type == "do_statement"
              or child_type == "for_statement"
              or child_type == "try_statement"
              or child_type == "case_statement"
              or child_type == "while_statement"
              or child_type == "throw_statement"
              or child_type == "return_statement"
              or child_type == "for_in_statement"
              or child_type == "switch_statement"
              or child_type == "default_statement"
              or child_type == "expression_statement"
          then
            complexity = complexity + 1
            -- utils.setVirtualText(ns_cc, body:start(), "+1", "cc", nil) -- signs.info.highlightGroup)
          end

          if
              child_type == "if_statement"
              or child_type == "do_statement"
              or child_type == "for_statement"
              or child_type == "try_statement"
              or child_type == "case_statement"
              or child_type == "while_statement"
              or child_type == "throw_statement"
              or child_type == "return_statement"
              or child_type == "for_in_statement"
              or child_type == "switch_statement"
              or child_type == "default_statement"
              or child_type == "expression_statement"
          then
            complexity = complexity + 1
            complexity = complexity + recurse_tree(body)
            -- utils.setVirtualText(ns_cc, body:start(), "+1", "cc", nil) -- signs.info.highlightGroup)
          end
        end
      end
    end

    -- local node1 = utils.walk_tree(node, {
    --   "lexical_declaration"
    -- })

    -- local node2 = utils.walk_tree(node, {
    --   "export_statement",
    --   "return_statement"
    -- })

    -- local line, col, _ = location(node1, node2, node)
    local line, col, _ = node:start()
    local to = node:end_()

    if complexity > 1 and complexity < 10 then
      utils.set_virtual_text(config.namespace, line, col, complexity, "Complexity", nil) --signs.info.highlightGroup)
    elseif complexity > 10 and complexity < 15 then
      utils.set_virtual_text(config.namespace, line, col, complexity, "Complexity", config.signs.hint.highlightGroup)

      utils.set_background(bufnr, config.namespace, line, to, config.signs.hint.highlightGroup)
    elseif complexity > 15 then
      utils.set_virtual_text(config.namespace, line, col, complexity, "Complexity", config.signs.error.highlightGroup)

      utils.set_background(bufnr, config.namespace, line, to, config.signs.error.highlightGroup)
    end
  end
end

function M.clear()
  vim.api.nvim_buf_clear_namespace(0, config.namespace, 0, -1)
end

return M
