export type value_node = primitive_node | array_node | object_node
export type primitive_node = {
	kind: 'value',
	value: string | number | boolean | nil,
	raw: string,
	start: number,
	finish: number,
}

export type array_node = {
	kind: 'array',
	elements: { value_node },
	start: number,
	finish: number,
}

export type object_node = {
	kind: 'object',
	properties: { property_node },
	start: number,
	finish: number,
}

export type property_node = {
	kind: 'property',
	key: string,
	value: value_node,
	start: number,
	finish: number,
}

return nil
