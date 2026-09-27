-- filters/xref-draft-placeholders.lua
--
-- Local draft-only filter.
-- Replaces unresolved section crossrefs with green "Section 0.0".
-- Use only for local single-chapter PDF layout work.

local function green_section_placeholder()
  return pandoc.RawInline(
    "latex",
    "\\textcolor{green!45!black}{Section~00.0}"
  )
end

-- Case 1: reference is still a Cite element
function Cite(el)
  if not (quarto.doc.is_format("latex") or quarto.doc.is_format("pdf")) then
    return nil
  end

  local placeholders = {}

  for _, citation in ipairs(el.citations) do
    local id = citation.id

    if not id:match("^[sS]ec%-") then
      return nil
    end

    table.insert(placeholders, "Section~00.0")
  end

  if #placeholders == 0 then
    return nil
  end

  return pandoc.RawInline(
    "latex",
    "\\textcolor{green!45!black}{" .. table.concat(placeholders, "; ") .. "}"
  )
end

-- Case 2: Quarto has already converted unresolved crossref to plain text:
-- (?@sec-something-long)
function Str(el)
  if not (quarto.doc.is_format("latex") or quarto.doc.is_format("pdf")) then
    return nil
  end

  if el.text:match("^%(%?@sec%-[^%)]+%)$") then
    return green_section_placeholder()
  end

  if el.text:match("^%?@sec%-") then
    return green_section_placeholder()
  end

  return nil
end