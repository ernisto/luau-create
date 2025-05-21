export type node = value_node | array_node | object_node
export type value_node = {
	kind: 'value',
	value: string | number | boolean | nil,
	raw: string,
	start: number,
	finish: number,
}

export type array_node = {
	kind: 'array',
	elements: { node },
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
	value: node,
	start: number,
	finish: number,
}

return nil
