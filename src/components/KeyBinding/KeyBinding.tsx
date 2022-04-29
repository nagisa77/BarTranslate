import { KeyBindingStyle, KeyBindingRow } from './styles';

interface KeyBindingProps {
  label: string
  defaultLabel: string
  divider?: true
}

export default function KeyBinding(props: KeyBindingProps): JSX.Element {
  return (
    <KeyBindingStyle>

      <KeyBindingRow>
        <span>{props.label}</span>
        <span>{props.defaultLabel}</span>
      </KeyBindingRow>

      {props.divider && <hr />}
    </KeyBindingStyle>
  );
}