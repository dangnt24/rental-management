import React from 'react';
import {
  LayoutDashboard, DoorOpen, Users, FileText, Receipt,
  CreditCard, AlertTriangle, UserCog, Building2, Tag,
  Circle
} from 'lucide-react';

const iconMap: Record<string, React.FC<{ className?: string }>> = {
  LayoutDashboard, DoorOpen, Users, FileText, Receipt,
  CreditCard, AlertTriangle, UserCog, Building2, Tag,
};

interface Props {
  name: string;
  className?: string;
}

const DynamicIcon: React.FC<Props> = ({ name, className }) => {
  const Icon = iconMap[name];
  if (!Icon) return <Circle className={className} />;
  return <Icon className={className} />;
};

export default DynamicIcon;
